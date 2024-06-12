// fcm.go
package main

import (
	"bufio"
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"

	"firebase.google.com/go/messaging"
)

// SendFCMNotification sends a notification to all the registered tokens.
func SendFCMNotification(client *messaging.Client, title, body string) error {
	file, err := os.Open("tokens.txt")
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		token := scanner.Text()

		message := &messaging.Message{
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
			},
			Token: token,
		}

		_, err := client.Send(context.Background(), message)
		if err != nil {
			log.Printf("Error sending FCM notification to token %s: %v", token, err)
		} else {
			log.Printf("Successfully sent FCM notification to token %s", token)
		}
	}

	if err := scanner.Err(); err != nil {
		return err
	}

	return nil
}

// RegisterTokenHandler handles the registration of new FCM tokens.
func RegisterTokenHandler(w http.ResponseWriter, r *http.Request) {
	var requestData struct {
		Token string `json:"token"`
	}

	err := json.NewDecoder(r.Body).Decode(&requestData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Save the token to your database or any persistent storage.
	// For example, saving to a file (this is just a simple example, you should use a database in production).
	file, err := os.OpenFile("tokens.txt", os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0600)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer file.Close()

	if _, err = file.WriteString(requestData.Token + "\n"); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Token registered successfully"))
}
