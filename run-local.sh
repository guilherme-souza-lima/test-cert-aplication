#!/bin/bash

# Script para executar versão local (HTTP/WS)

echo "🚀 Executando WebSocket Local (HTTP/WS)"
echo "======================================"

cd local

# Instalar dependências
echo "📦 Instalando dependências..."
go mod tidy

# Executar servidor
echo "🌐 Iniciando servidor local na porta 5678..."
go run main.go
