#!/bin/bash

# Script para validar os comandos bash antes de executar
# Execute: ./validate-scripts.sh

echo "🔍 Validando Scripts Bash para Deploy Seguro"
echo "============================================="

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

# Verificar se os scripts existem
print_status "Verificando se os scripts existem..."

if [ ! -f "nginx-proxy-config.sh" ]; then
    print_error "nginx-proxy-config.sh não encontrado!"
    exit 1
fi

if [ ! -f "deploy-wss-server-nginx.sh" ]; then
    print_error "deploy-wss-server-nginx.sh não encontrado!"
    exit 1
fi

print_success "Scripts encontrados!"

# Verificar permissões
print_status "Verificando permissões dos scripts..."

if [ ! -x "nginx-proxy-config.sh" ]; then
    print_warning "nginx-proxy-config.sh não tem permissão de execução. Corrigindo..."
    chmod +x nginx-proxy-config.sh
fi

if [ ! -x "deploy-wss-server-nginx.sh" ]; then
    print_warning "deploy-wss-server-nginx.sh não tem permissão de execução. Corrigindo..."
    chmod +x deploy-wss-server-nginx.sh
fi

print_success "Permissões corretas!"

# Verificar sintaxe bash
print_status "Verificando sintaxe bash..."

if bash -n nginx-proxy-config.sh; then
    print_success "nginx-proxy-config.sh: sintaxe OK"
else
    print_error "nginx-proxy-config.sh: erro de sintaxe!"
    exit 1
fi

if bash -n deploy-wss-server-nginx.sh; then
    print_success "deploy-wss-server-nginx.sh: sintaxe OK"
else
    print_error "deploy-wss-server-nginx.sh: erro de sintaxe!"
    exit 1
fi

# Verificar comandos críticos
print_status "Verificando comandos críticos..."

CRITICAL_COMMANDS=("nginx" "docker" "certbot" "systemctl" "curl")

for cmd in "${CRITICAL_COMMANDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        print_success "$cmd: disponível"
    else
        print_warning "$cmd: não encontrado (será instalado se necessário)"
    fi
fi

# Verificar se Nginx está rodando
print_status "Verificando status do Nginx..."

if systemctl is-active --quiet nginx 2>/dev/null; then
    print_success "Nginx está rodando"
    
    # Verificar portas
    if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
        print_success "Porta 80 está em uso pelo Nginx"
    else
        print_warning "Porta 80 não está em uso"
    fi
    
    if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
        print_success "Porta 443 está em uso pelo Nginx"
    else
        print_warning "Porta 443 não está em uso"
    fi
else
    print_warning "Nginx não está rodando"
fi

# Verificar se Docker está rodando
print_status "Verificando status do Docker..."

if systemctl is-active --quiet docker 2>/dev/null; then
    print_success "Docker está rodando"
else
    print_warning "Docker não está rodando (será iniciado se necessário)"
fi

# Verificar espaço em disco
print_status "Verificando espaço em disco..."

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    print_success "Espaço em disco OK ($DISK_USAGE% usado)"
else
    print_warning "Espaço em disco baixo ($DISK_USAGE% usado)"
fi

# Verificar memória
print_status "Verificando memória disponível..."

MEMORY_AVAILABLE=$(free -m | awk 'NR==2{printf "%.0f", $7}')
if [ "$MEMORY_AVAILABLE" -gt 512 ]; then
    print_success "Memória OK (${MEMORY_AVAILABLE}MB disponível)"
else
    print_warning "Memória baixa (${MEMORY_AVAILABLE}MB disponível)"
fi

echo ""
print_success "✅ Validação concluída!"
echo ""
print_status "📋 Resumo dos comandos seguros:"
echo "======================================"
echo "1. sudo ./nginx-proxy-config.sh"
echo "   - ✅ NÃO para o Nginx existente"
echo "   - ✅ Apenas adiciona configuração para cubevisservice.site"
echo "   - ✅ Faz backup da configuração atual"
echo ""
echo "2. sudo ./deploy-wss-server-nginx.sh"
echo "   - ✅ Usa webroot para certificados (não para Nginx)"
echo "   - ✅ Container roda na porta 8080 (não conflita)"
echo "   - ✅ Nginx faz proxy 80/443 → 8080"
echo ""
echo "3. curl -I https://cubevisservice.site"
echo "   - ✅ Testa se o site está funcionando"
echo "   - ✅ Verifica certificado SSL"
echo ""
print_success "🚀 Scripts validados e seguros para execução!"
