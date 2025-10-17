#!/bin/bash

# Script para build e execução do WebSocket Server via Docker
# Porta: 5678

echo "🐳 WebSocket Server - Build e Execução"
echo "======================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose não encontrado. Usando apenas Docker."
    USE_COMPOSE=false
else
    USE_COMPOSE=true
fi

# Parar containers existentes
print_status "Parando containers existentes..."
if [ "$USE_COMPOSE" = true ]; then
    docker-compose down 2>/dev/null || true
else
    docker stop websocket-random-numbers 2>/dev/null || true
    docker rm websocket-random-numbers 2>/dev/null || true
fi

# Build da imagem
print_status "Fazendo build da imagem Docker..."
if [ "$USE_COMPOSE" = true ]; then
    docker-compose build --no-cache
else
    docker build -t websocket-server .
fi

if [ $? -eq 0 ]; then
    print_success "Build concluído com sucesso!"
else
    print_error "Erro no build da imagem Docker."
    exit 1
fi

# Executar container
print_status "Iniciando container..."
if [ "$USE_COMPOSE" = true ]; then
    docker-compose up -d
else
    docker run -d \
        --name websocket-random-numbers \
        -p 5678:5678 \
        --restart unless-stopped \
        websocket-server
fi

if [ $? -eq 0 ]; then
    print_success "Container iniciado com sucesso!"
else
    print_error "Erro ao iniciar o container."
    exit 1
fi

# Aguardar container ficar pronto
print_status "Aguardando container ficar pronto..."
sleep 5

# Verificar se o container está rodando
if docker ps | grep -q websocket-random-numbers; then
    print_success "Container está rodando!"
    
    # Mostrar informações
    echo ""
    echo "🌐 Informações do Servidor:"
    echo "=========================="
    echo "URL: http://localhost:5678"
    echo "WebSocket: ws://localhost:5678/ws"
    echo "Container: websocket-random-numbers"
    echo ""
    
    # Mostrar logs
    print_status "Últimas linhas dos logs:"
    docker logs --tail 10 websocket-random-numbers
    
    echo ""
    print_success "Servidor WebSocket está rodando na porta 5678!"
    print_status "Para parar: docker stop websocket-random-numbers"
    print_status "Para ver logs: docker logs -f websocket-random-numbers"
    
else
    print_error "Container não está rodando. Verificando logs..."
    docker logs websocket-random-numbers
    exit 1
fi
