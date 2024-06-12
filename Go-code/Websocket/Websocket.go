// package main

// import (
// 	"log"
// 	"net/http"

// 	"github.com/gorilla/mux"
// 	"github.com/streadway/amqp"
	
// 	"github.com/gorilla/websocket"
// )

// var (
// 	clients = make(map[*websocket.Conn]bool)
// 	broadcast= make(chan []byte) //channel to broadcast the mssg from response queue to all available client
// 	upgrader= websocket.Upgrader{
// 		ReadBufferSize:  1024,
//         WriteBufferSize: 1024,
//         CheckOrigin: func(r *http.Request) bool {
//         return true // Allow all connections by default
//     },
// 	}
// )
// func ConnectToRabbitMQ() (*amqp.Connection, *amqp.Channel) {
//     conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
//     Error(err, "Failed to connect to RabbitMQ")
//     ch, err := conn.Channel()
//     Error(err, "Failed to open a channel")
//     return conn, ch
// }

// func Error(err error, msg string){
// 	if err != nil{
// 		log.Fatalf("%s : %s",msg,err)
// 	}
// }


// //This function upgrades the Get request from the client to turn it into websocket TCP 
// //Using upgrade method that return websocket connection pointer

// func handleincomingwebsocketconnection(w http.ResponseWriter, r *http.Request){
// 	ws,err := upgrader.Upgrade(w,r,nil)
// 	if err!=nil{
// 		log.Fatalf("Failed to upgrade to websocket: %s",err)

// 	}
// 	defer ws.Close()
// 	clients[ws]= true //Ensure the connection is made

// 	for {
// 		_,_, err:= ws.ReadMessage() //Read the mssg from client 
// 		if err!=nil { //If there is no mssg deletes the client server connection
// 			log.Println("Error Reading the message:",err)
// 			break
// 		}
// 	}

// }



// //Consume the Satricial Response that is to be sent to the client
// func SatricialResponse(ch *amqp.Channel) <-chan amqp.Delivery{
//    q, err := ch.QueueDeclare(
//         "response_queue", // Name of the queue for responses
//         false,            // Durable
//         false,            // Delete when unused
//         false,            // Exclusive
//         false,            // No-wait
//         nil,              // Arguments
//     )
//     Error(err, "Failed to declare a queue")

//     msgs, err := ch.Consume(
//         q.Name, // Queue name
//         "",     // Consumer name
//         true,   // Auto acknowledge
//         false,  // Exclusive
//         false,  // No local
//         false,  // No wait
//         nil,    // Args
//     )
//     Error(err, "Failed to register a consumer")

//     return msgs
// }

// func handlemssgs(){
   
// 	notification := <-broadcast
// 	for client := range clients{
// 		err:= client.WriteMessage(websocket.TextMessage,notification)
// 		if err!=nil {
// 			log.Println("Error sending message: %s",err)
// 			client.Close()
// 			delete(clients,client)
// 	}
//   }
// }










// func main(){

// 	r:= mux.NewRouter()

// 	r.HandleFunc("/ws",handleincomingwebsocketconnection)

// 	go func(){
// 		log.Fatal(http.ListenAndServe(":8080",r))

// 	}()
	
// 	conn,ch:=ConnectToRabbitMQ()
// 	defer conn.Close()
// 	defer ch.Close()

// 	responseMsgs := SatricialResponse(ch)

// 	go func (){
// 		for d := range responseMsgs {
// 			log.Printf("Recieved response:%s",d.Body)
// 			broadcast<-d.Body
// 		}
// 	}()
// 	handlemssgs()

// }
 