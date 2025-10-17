#!/bin/bash

# Script para resolver conflito de porta 80
# Execute no servidor: sudo ./fix-port-80.sh

echo "🔧 Resolvendo conflito de porta 80"
echo "=================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Verificar o que está usando a porta 80
print_status "Verificando o que está usando a porta 80..."

# Verificar Apache
if systemctl is-active --quiet apache2; then
    print_warning "Apache2 está rodando na porta 80"
    print_status "Parando Apache2..."
    systemctl stop apache2
    systemctl disable apache2
    print_success "Apache2 parado e desabilitado"
fi

# Verificar Nginx
if systemctl is-active --quiet nginx; then
    print_warning "Nginx está rodando na porta 80"
    print_status "Parando Nginx..."
    systemctl stop nginx
    systemctl disable nginx
    print_success "Nginx parado e desabilitado"
fi

# Verificar outros serviços
print_status "Verificando outros serviços na porta 80..."
PORT_80_PROCESSES=$(lsof -i :80 2>/dev/null || netstat -tlnp | grep :80)

if [ -n "$PORT_80_PROCESSES" ]; then
    print_warning "Processos ainda usando porta 80:"
    echo "$PORT_80_PROCESSES"
    
    # Matar processos na porta 80
    print_status "Parando processos na porta 80..."
    fuser -k 80/tcp 2>/dev/null || true
    sleep 2
fi

# Verificar se a porta 80 está livre
print_status "Verificando se porta 80 está livre..."
if lsof -i :80 >/dev/null 2>&1; then
    print_error "Porta 80 ainda está em uso!"
    print_status "Processos usando porta 80:"
    lsof -i :80
    exit 1
else
    print_success "Porta 80 está livre!"
fi

# Verificar se a porta 443 está livre
print_status "Verificando se porta 443 está livre..."
if lsof -i :443 >/dev/null 2>&1; then
    print_warning "Porta 443 está em uso, mas isso pode ser normal"
    lsof -i :443
else
    print_success "Porta 443 está livre!"
fi

print_success "Conflito de porta resolvido!"
print_status "Agora você pode executar: sudo ./deploy-wss-server.sh"
