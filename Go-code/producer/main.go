package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"google.golang.org/api/option"

	"context"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/gorilla/mux"
	"github.com/streadway/amqp"
)

// Datatype of the json file
type data struct {
	Appname  string `json:"appname"`
	Severity int    `json:"severity"`
	Message  string `json:"message"`
}

// Common function to handle Error
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
var response_queue = "response_queue"

// Declaring the queue and publishing so that it gets consumed in Python script
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

func SatricialResponse(ch *amqp.Channel) <-chan amqp.Delivery { //` here it takes rabbitMQ channel as arguments and return type is also channel
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
		q.Name,         // Queue name
		response_queue, // Consumer name
		true,           // Auto acknowledge
		false,          // Exclusive
		false,          // No local
		false,          // No wait
		nil,            // Args
	)
	failOnError(err, "Failed to register a consumer")

	return msgs
}

// Handle the Post request sent by client along with Json file to generate the Satricial notification
func responserhandler(w http.ResponseWriter, r *http.Request) {
	print("response received")
	var resdata data
	decoder := json.NewDecoder(r.Body)
	println(decoder)
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

func initReponse(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Server is alive"))
}

func main() {
	// Firebase setup
	// Create a new router
	r := mux.NewRouter()
	opt := option.WithCredentialsFile("./firebase.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	ctx := context.Background()
	client, err := app.Messaging(ctx)
	if err != nil {
		log.Fatalf("error getting Messaging client: %v\n", err)
	}
	var topic = "xxx"
	// var registrationtoken = `dt_TSiupQd64ATvznQWPIo:APA91bF8nT6uCyoYuMAj07uZy7wKhYUVAaWKphbuK5NhoA68LRVp8JVtoqInqzBulIbaR2c5UJhuzw5c1D8kwfq17HSiRDDXj2dNRfDJeMwlgI-vWOYfxzsLrbxEUip1zAYtItORQLDk`

	message := &messaging.Message{
		Data: map[string]string{"message": "suman herooo"},
		// Token: registrationtoken,
		Topic: topic,
	}
	r.HandleFunc("/sendmessage", func(w http.ResponseWriter, r *http.Request) {
		// Trigger to send the cloud message
		response, err := client.Send(ctx, message)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		fmt.Fprintf(w, "Cloud message sent: %s", response)
	}).Methods("GET")
	if err != nil {
		log.Fatalln(err)
	}
	// Response is a message ID string.

	// Defining the route and its handler function
	conn, ch := ConnectToRabbitMQ()
	defer conn.Close()
	defer ch.Close()

	r.HandleFunc("/app/notify", responserhandler).Methods("POST")
	r.HandleFunc("/", initReponse).Methods("GET")

	// r.HandleFunc("/register_token", RegisterTokenHandler).Methods("Post")
	log.Fatal(http.ListenAndServe(":8080", r))

	responses := SatricialResponse(ch)
	println("responses", responses)
	// Start the HTTP server
	go func() {
		for d := range responses {
			log.Printf("Received a message: %s", d.Body)
		}
	}()

	select {} // Block forever
}
