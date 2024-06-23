package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	
    "firebase.google.com/go"
    "firebase.google.com/go/messaging"
    "google.golang.org/api/option"
)

type NotificationRequest struct {
	Type string `json:"type"`
	ID   string `json:"id"`
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

func handleNotify(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        http.Error(w, "Method is not supported.", http.StatusMethodNotAllowed)
        return
    }

    var notifReq NotificationRequest
    err := json.NewDecoder(r.Body).Decode(&notifReq)
    if err != nil {
        http.Error(w, "Failed to parse request body", http.StatusBadRequest)
        log.Printf("Failed to parse request body: %v\n", err)
        return
    }

    if notifReq.Type != "token" && notifReq.Type != "topic" {
        http.Error(w, "Invalid type, must be 'token' or 'topic'", http.StatusBadRequest)
        log.Printf("Invalid type: %s\n", notifReq.Type)
        return
    }
    if notifReq.ID == "" {
        http.Error(w, "ID is required", http.StatusBadRequest)
        log.Printf("ID is required\n")
        return
    }

    var message *messaging.Message
    if notifReq.Type == "token" {
        message = &messaging.Message{
            Token: notifReq.ID,
            Notification: &messaging.Notification{
                Title: "New Notification",
                Body:  "Motherfuckers",
            },
        }
    } else {
        message = &messaging.Message{
            Topic: notifReq.ID,
            Notification: &messaging.Notification{
                Title: "New Notification",
                Body:  "Motherfuckers",
            },
        }
    }

    response, err := fbMessaging.Send(context.Background(), message)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to send message: %v", err), http.StatusInternalServerError)
        log.Printf("Failed to send message: %v\n", err)
        return
    }

    fmt.Printf("Successfully sent message: %s\n", response)
    fmt.Fprintf(w, "Successfully sent message: %s\n", response)
}


func main() {
	// Initialize Firebase app
	initFirebaseApp()
	initFirebaseMessaging()
	
	fmt.Printf("Starting server at port 8080\n")
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello world")
	})
	http.HandleFunc("/notify", handleNotify)

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}


// Android package name: com.progress.appx, App nickname: progress-fcm-test01