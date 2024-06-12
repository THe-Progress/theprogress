
package main


import (
    "context"

    firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
    "google.golang.org/api/option"
)

func FirebaseInit(ctx context.Context) (*messaging.Client, error) {
    // Use the path to your service account credential json file
    opt := option.WithCredentialsFile("./firebase.json")
    // Create a new firebase app
    app, err := firebase.NewApp(ctx, nil, opt)
    if err != nil {
        return nil, err
    }
    // Get the FCM object
    fcmClient, err := app.Messaging(ctx)
    if err != nil {
        return nil, err
    }
    return fcmClient, nil
}

func SendNotification(
    fcmClient *messaging.Client,
    ctx context.Context,
    tokens []string,
	message string,
) error {
    //Send to One Token
    _, err := fcmClient.Send(ctx, &messaging.Message{
        Token: tokens[0],
        Data: map[string]string{
            message: message,
        },
    })
    if err != nil {
        return err
    }

    //Send to Multiple Tokens
    _, err = fcmClient.SendMulticast(ctx, &messaging.MulticastMessage{
        Data: map[string]string{
            message: message,
        },
        Tokens: tokens,
    })
    return err
}