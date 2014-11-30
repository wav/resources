package main

import (
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

func CommandHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	err = handleMessages(conn)
	if err != nil {
		log.Println(err)
		return
	}
}

func handleMessages(conn *websocket.Conn) error {
	for {
		messageType, p, err := conn.ReadMessage()
		if err != nil {
			return err
		}
		if err = conn.WriteMessage(messageType, p); err != nil {
			return err
		}
	}
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/commandBus", CommandHandler)
	http.Handle("/", r)
	err := http.ListenAndServe(":8123", nil)
	if err != nil {
		log.Fatal(err)
	}
}
