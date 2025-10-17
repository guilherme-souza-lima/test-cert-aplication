package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
)

var wssUpgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Permite conexões de qualquer origem
	},
}

type WSSMessage struct {
	Number int `json:"number"`
}

func handleWSSWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := wssUpgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Erro ao fazer upgrade para WebSocket: %v", err)
		return
	}
	defer conn.Close()

	log.Printf("Cliente conectado via WSS: %s", r.RemoteAddr)

	// Canal para controlar o envio de números
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		// Gera um número aleatório
		randomNumber := rand.Intn(1000)

		// Cria a mensagem
		message := WSSMessage{Number: randomNumber}

		// Envia a mensagem como JSON
		if err := conn.WriteJSON(message); err != nil {
			log.Printf("Erro ao enviar mensagem: %v", err)
			return
		}

		log.Printf("Número enviado via WSS: %d", randomNumber)
	}
}

func main() {
	// Inicializa o gerador de números aleatórios
	rand.Seed(time.Now().UnixNano())

	// Rota para WebSocket
	http.HandleFunc("/ws", handleWSSWebSocket)

	// Rota para página de teste
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		html := `
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Seguro - Números Aleatórios</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .number { 
            background: #e8f5e8; 
            border: 1px solid #4CAF50; 
            border-radius: 5px; 
            padding: 10px; 
            margin: 5px; 
            display: inline-block;
            min-width: 100px;
            text-align: center;
        }
        .status { 
            background: #f0f8ff; 
            border: 1px solid #2196F3; 
            border-radius: 5px; 
            padding: 10px; 
            margin: 10px 0;
        }
        .secure { color: #4CAF50; font-weight: bold; }
    </style>
</head>
<body>
    <h1>🔒 WebSocket Seguro (WSS) - Números Aleatórios</h1>
    <div class="status">
        <p><span class="secure">✓ Conexão Segura</span> - Usando WSS (WebSocket Secure)</p>
        <p>Domínio: <strong>cubevisservice.site</strong></p>
    </div>
    <div id="numbers"></div>
    
    <script>
        // Detectar se estamos em HTTPS ou HTTP
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = protocol + '//' + window.location.host + '/ws';
        
        const ws = new WebSocket(wsUrl);
        const numbersDiv = document.getElementById('numbers');
        
        ws.onopen = function(event) {
            console.log('Conectado ao WebSocket Seguro (WSS)');
            addStatusMessage('Conectado ao WebSocket Seguro', 'success');
        };
        
        ws.onmessage = function(event) {
            const data = JSON.parse(event.data);
            const numberElement = document.createElement('div');
            numberElement.className = 'number';
            numberElement.textContent = data.number;
            numbersDiv.appendChild(numberElement);
            
            // Mantém apenas os últimos 15 números
            if (numbersDiv.children.length > 15) {
                numbersDiv.removeChild(numbersDiv.firstChild);
            }
        };
        
        ws.onclose = function(event) {
            console.log('Conexão WebSocket fechada');
            addStatusMessage('Conexão fechada', 'error');
        };
        
        ws.onerror = function(error) {
            console.log('Erro no WebSocket:', error);
            addStatusMessage('Erro na conexão', 'error');
        };
        
        function addStatusMessage(message, type) {
            const statusDiv = document.querySelector('.status');
            const p = document.createElement('p');
            p.textContent = message;
            p.style.color = type === 'success' ? '#4CAF50' : '#f44336';
            statusDiv.appendChild(p);
        }
    </script>
</body>
</html>
		`
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprint(w, html)
	})

	// Configuração TLS
	tlsConfig := &tls.Config{
		MinVersion: tls.VersionTLS12,
	}

	// Configuração do servidor HTTPS
	server := &http.Server{
		Addr:      ":443",
		TLSConfig: tlsConfig,
	}

	// Servidor HTTP para redirecionar para HTTPS
	go func() {
		httpServer := &http.Server{
			Addr: ":80",
			Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				http.Redirect(w, r, "https://"+r.Host+r.RequestURI, http.StatusMovedPermanently)
			}),
		}
		log.Println("Servidor HTTP iniciado em :80 (redireciona para HTTPS)")
		log.Fatal(httpServer.ListenAndServe())
	}()

	log.Println("Servidor WSS iniciado em https://cubevisservice.site:443")
	log.Println("WebSocket seguro disponível em wss://cubevisservice.site:443/ws")
	log.Println("Certificados SSL necessários em /etc/letsencrypt/live/cubevisservice.site/")

	// Iniciar servidor HTTPS
	log.Fatal(server.ListenAndServeTLS(
		"/etc/letsencrypt/live/cubevisservice.site/fullchain.pem",
		"/etc/letsencrypt/live/cubevisservice.site/privkey.pem",
	))
}
