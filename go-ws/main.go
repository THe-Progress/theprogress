package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/streadway/amqp"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
)

// Datatype of the json file
type Data struct {
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

// Connecting to the RabbitMQ server
func ConnectToRabbitMQ() (*amqp.Connection, *amqp.Channel) {
	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
	failOnError(err, "Failed to connect to RabbitMQ")
	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	return conn, ch
}

var generateQueue = "generate_queue"
var responseQueue = "response_queue"

// Declaring the queue and publishing so that it gets consumed in Python script
func prompt(ch *amqp.Channel, resdata Data) {
	jsonData, err := json.Marshal(resdata)
	if err != nil {
		log.Fatalf("Error converting struct to JSON: %v", err)
	}
	q, err := ch.QueueDeclare(
		generateQueue, // name
		false,         // durable
		false,         // delete when unused
		false,         // exclusive
		false,         // no-wait
		nil,           // arguments
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

// Handling the responseQueue declared in the Python script
func SatiricalResponse(ch *amqp.Channel) <-chan amqp.Delivery {
	q, err := ch.QueueDeclare(
		responseQueue, // Name of the queue for responses
		false,         // Durable
		false,         // Delete when unused
		false,         // Exclusive
		false,         // No-wait
		nil,           // Arguments
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

// Handle the POST request sent by client along with JSON file to generate the satirical notification
func responserhandler(w http.ResponseWriter, r *http.Request) {
	var resdata Data
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

func initResponse(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Server is alive"))
}

var fbApp *firebase.App
var fbMessaging *messaging.Client

func initFirebaseApp() {
	opt := option.WithCredentialsFile("./firebase.json") // Replace with your actual path
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	fbApp = app
}
func initFirebaseMessaging() {
	ctx := context.Background()
	client, err := fbApp.Messaging(ctx)
	if err != nil {
		log.Fatalf("error getting Messaging client: %v\n", err)
	}
	fbMessaging = client
}

func sendFCMNotification(message string) {
	// Create the FCM message
	msg := &messaging.Message{
		Topic: "all",
		Notification: &messaging.Notification{
			Title: "We are watching you!",
			Body:  message,
		},
	}

	// Send the FCM message
	response, err := fbMessaging.Send(context.Background(), msg)
	if err != nil {
		log.Printf("Failed to send message: %v\n", err)
		return
	}
	log.Printf("Successfully sent message: %s\n", response)
}

func main() {
	// Initialize Firebase app and messaging client
	initFirebaseApp()
	initFirebaseMessaging()

	// Create a new router
	r := mux.NewRouter()

	// Defining the route and its handler function
	conn, ch := ConnectToRabbitMQ()
	defer conn.Close()
	defer ch.Close()

	r.HandleFunc("/app/notify", responserhandler).Methods("POST")
	r.HandleFunc("/", initResponse).Methods("GET")

	// Start the HTTP server
	go func() {
		log.Fatal(http.ListenAndServe(":8080", r))
	}()

	// Consume messages from the response queue and send FCM notifications
	responses := SatiricalResponse(ch)
	go func() {
		for d := range responses {
			log.Printf("Received a message: %s", d.Body)
			sendFCMNotification(string(d.Body))
		}
	}()

	// Block forever
	select {}
}
