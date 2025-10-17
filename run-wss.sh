#!/bin/bash

# Script para executar versão WSS (HTTPS/WSS)

echo "🔒 Executando WebSocket WSS (HTTPS/WSS)"
echo "======================================"

cd wss

# Instalar dependências
echo "📦 Instalando dependências..."
go mod tidy

# Verificar se certificados existem
if [ ! -d "/etc/letsencrypt/live/cubevisservice.site" ]; then
    echo "❌ Certificados SSL não encontrados!"
    echo "Execute primeiro: sudo ./setup_wss.sh"
    exit 1
fi

# Executar servidor WSS
echo "🔒 Iniciando servidor WSS..."
go run wss_server.go
