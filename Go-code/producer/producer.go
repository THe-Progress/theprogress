package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	
    
	"firebase.google.com/go"
	
	"github.com/gorilla/mux"
	"github.com/streadway/amqp"
	"google.golang.org/api/option"
)

//Datatype of the json file
type data struct {
	Appname  string `json:"appname"`
	Severity int    `json:"severity"`
	Message  string `json:"message"`
}

//Common function to handle Error
func failOnError(err error, msg string) {
	if err != nil {
		log.Fatalf("%s: %s", msg, err)
	}
}

//Connecting to the RabbbitMQ server

func ConnectToRabbitMQ() (*amqp.Connection, *amqp.Channel) {
	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
	failOnError(err, "Failed to connect to RabbitMQ")
	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	return conn, ch
}

var queueName = "notification_queue"


//Declaring the queue and publishing so that it gets consumed in Python script
func prompt(ch *amqp.Channel, resdata data) {
	jsonData, err := json.Marshal(resdata)
	if err != nil {
		log.Fatalf("Error converting struct to JSON: %v", err)
	}
	q, err := ch.QueueDeclare(
		queueName, // name
		false,     // durable
		false,     // delete when unused
		false,     // exclusive
		false,     // no-wait
		nil,       // arguments
	)
	failOnError(err, "Failed to declare a queue")

	err = ch.Publish(
		"",     // exchange
		q.Name, // routing key
		false,  // mandatory
		false,  // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        jsonData,
		})
	failOnError(err, "Failed to publish a message")
	log.Printf(" [x] Sent %s", jsonData)
}

//Handling the response_queue delared in python script

func SatricialResponse(ch *amqp.Channel) <-chan amqp.Delivery { //here it takes rabbitMQ channel as arguments and return type is also channel
	q, err := ch.QueueDeclare(
		"response_queue", // Name of the queue for responses
		false,            // Durable
		false,            // Delete when unused
		false,            // Exclusive
		false,            // No-wait
		nil,              // Arguments
	)
	failOnError(err, "Failed to declare a queue")

	msgs, err := ch.Consume(
		q.Name, // Queue name
		"",     // Consumer name
		true,   // Auto acknowledge
		false,  // Exclusive
		false,  // No local
		false,  // No wait
		nil,    // Args
	)
	failOnError(err, "Failed to register a consumer")

	return msgs
}

//Handle the Post request sent by client along with Json file to generate the Satricial notification
func responserhandler(w http.ResponseWriter, r *http.Request) {
	var resdata data
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&resdata)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	conn, ch := ConnectToRabbitMQ()
	defer conn.Close()
	defer ch.Close()

	prompt(ch, resdata)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Message sent to RabbitMQ"))
}



func main() {
	// Firebase setup
	opt := option.WithCredentialsFile("progress1-8506d-firebase-adminsdk-1ad4s-e6d49e3f61.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v", err)
	}

	client, err := app.Messaging(context.Background())
	if err != nil {
		log.Fatalf("error getting Messaging client: %v", err)
	}

	// Create a new router
	r := mux.NewRouter()

	// Defining the route and its handler function
	r.HandleFunc("/app/notify", responserhandler).Methods("POST")
    r.HandleFunc("/register_token",RegisterTokenHandler).Methods("Post")

	// Start the HTTP server
	go func() {
		log.Fatal(http.ListenAndServe(":8080", r))
	}()

	conn, ch := ConnectToRabbitMQ()
	defer conn.Close()
	defer ch.Close()

	responseMsgs := SatricialResponse(ch)

    // I am able to get the AI generated Satirical Message. It is tested. Even the Python Script Runs Properly.I request Someone to Manage the FCM messaging 
    // done after this

	go func() {
		for d := range responseMsgs {
			log.Printf("Received response: %s", d.Body)



			
      var notification struct {
        Title string `json:"title"`
        Body  string `json:"body"`
      }

      if err := json.Unmarshal(d.Body, &notification); err != nil {
        log.Printf("Error unmarshaling the message: %s", err)
        continue
      }

      // Send the notification to all registered tokens
      if err := SendFCMNotification(client, notification.Title, notification.Body); err != nil {
        log.Printf("Error sending FCM notification: %s", err)
      }
		}
	}()

	select {} // Block forever
}
