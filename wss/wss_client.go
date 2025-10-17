package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"net/url"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/websocket"
)

type WSSClientMessage struct {
	Number int `json:"number"`
}

func main() {
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	// Configurar TLS para aceitar certificados auto-assinados (apenas para teste)
	tlsConfig := &tls.Config{
		InsecureSkipVerify: true, // ⚠️ APENAS PARA TESTE - NÃO USAR EM PRODUÇÃO
	}

	u := url.URL{Scheme: "wss", Host: "cubevisservice.site", Path: "/ws"}
	log.Printf("🔒 Conectando via WSS para %s", u.String())

	dialer := websocket.Dialer{
		TLSClientConfig: tlsConfig,
	}

	c, _, err := dialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("❌ Erro ao conectar:", err)
	}
	defer c.Close()

	log.Println("✅ Conectado com sucesso via WSS!")

	done := make(chan struct{})

	go func() {
		defer close(done)
		for {
			var message WSSClientMessage
			err := c.ReadJSON(&message)
			if err != nil {
				log.Println("❌ Erro ao ler mensagem:", err)
				return
			}
			fmt.Printf("🔢 Número recebido via WSS: %d\n", message.Number)
		}
	}()

	for {
		select {
		case <-done:
			return
		case <-interrupt:
			log.Println("🛑 Interrompendo conexão...")

			// Enviar mensagem de fechamento para o servidor
			err := c.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("❌ Erro ao fechar:", err)
				return
			}
			select {
			case <-done:
			case <-time.After(time.Second):
			}
			return
		}
	}
}
