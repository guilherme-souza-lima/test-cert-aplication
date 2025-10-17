package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Permite conexões de qualquer origem
	},
}

type Message struct {
	Number int `json:"number"`
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Erro ao fazer upgrade para WebSocket: %v", err)
		return
	}
	defer conn.Close()

	log.Printf("Cliente conectado: %s", r.RemoteAddr)

	// Canal para controlar o envio de números
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		// Gera um número aleatório
		randomNumber := rand.Intn(1000)

		// Cria a mensagem
		message := Message{Number: randomNumber}

		// Envia a mensagem como JSON
		if err := conn.WriteJSON(message); err != nil {
			log.Printf("Erro ao enviar mensagem: %v", err)
			return
		}

		log.Printf("Número enviado: %d", randomNumber)
	}
}

func main() {
	// Inicializa o gerador de números aleatórios
	rand.Seed(time.Now().UnixNano())

	// Rota para WebSocket
	http.HandleFunc("/ws", handleWebSocket)

	// Rota para página de teste
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		html := `
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Números Aleatórios</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>WebSocket - Números Aleatórios</h1>
    <div id="numbers"></div>
    
    <script>
        const ws = new WebSocket('ws://localhost:5678/ws');
        const numbersDiv = document.getElementById('numbers');
        
        ws.onopen = function(event) {
            console.log('Conectado ao WebSocket');
        };
        
        ws.onmessage = function(event) {
            const data = JSON.parse(event.data);
            const numberElement = document.createElement('div');
            numberElement.textContent = 'Número: ' + data.number;
            numberElement.style.margin = '5px';
            numberElement.style.padding = '10px';
            numberElement.style.backgroundColor = '#f0f0f0';
            numberElement.style.border = '1px solid #ccc';
            numberElement.style.borderRadius = '5px';
            numbersDiv.appendChild(numberElement);
            
            // Mantém apenas os últimos 10 números
            if (numbersDiv.children.length > 10) {
                numbersDiv.removeChild(numbersDiv.firstChild);
            }
        };
        
        ws.onclose = function(event) {
            console.log('Conexão WebSocket fechada');
        };
        
        ws.onerror = function(error) {
            console.log('Erro no WebSocket:', error);
        };
    </script>
</body>
</html>
		`
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, html)
	})

	log.Println("Servidor iniciado em http://localhost:5678")
	log.Println("WebSocket disponível em ws://localhost:5678/ws")
	log.Fatal(http.ListenAndServe(":5678", nil))
}
