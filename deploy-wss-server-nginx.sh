#!/bin/bash

# Script de Deploy para WebSocket WSS com Nginx como Proxy
# Execute no servidor: sudo ./deploy-wss-server-nginx.sh

echo "🚀 Deploy WebSocket WSS com Nginx Proxy - Servidor de Produção"
echo "=============================================================="

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

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker não está instalado. Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    print_success "Docker instalado com sucesso!"
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose não encontrado. Instalando..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose instalado!"
fi

# Verificar se o domínio está configurado
print_status "Verificando configuração do domínio cubevisservice.site..."
if ! nslookup cubevisservice.site &> /dev/null; then
    print_warning "Domínio cubevisservice.site não está resolvendo. Verifique o DNS."
    read -p "Continuar mesmo assim? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Instalar Certbot se não estiver instalado
if ! command -v certbot &> /dev/null; then
    print_status "Instalando Certbot..."
    apt update
    apt install -y snapd
    snap install core; snap refresh core
    snap install --classic certbot
    ln -sf /snap/bin/certbot /usr/bin/certbot
    print_success "Certbot instalado!"
fi

# Obter certificado SSL se não existir
if [ ! -d "/etc/letsencrypt/live/cubevisservice.site" ]; then
    print_status "Obtendo certificado SSL para cubevisservice.site..."
    
    # Usar webroot em vez de standalone para não parar Nginx
    if certbot certonly --webroot -w /var/www/html -d cubevisservice.site --non-interactive --agree-tos --email admin@cubevisservice.site; then
        print_success "Certificado SSL obtido com sucesso!"
    else
        print_warning "Tentando método standalone como fallback..."
        # Só para Nginx se webroot falhar
        systemctl stop nginx
        if certbot certonly --standalone -d cubevisservice.site --non-interactive --agree-tos --email admin@cubevisservice.site; then
            print_success "Certificado SSL obtido com sucesso!"
            systemctl start nginx
        else
            print_error "Erro ao obter certificado SSL. Verifique se:"
            print_error "1. O domínio cubevisservice.site aponta para este servidor"
            print_error "2. As portas 80 e 443 estão abertas"
            print_error "3. O Nginx está configurado corretamente"
            systemctl start nginx
            exit 1
        fi
    fi
else
    print_success "Certificado SSL já existe!"
fi

# Configurar renovação automática
print_status "Configurando renovação automática de certificados..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && systemctl reload nginx") | crontab -

# Configurar firewall
print_status "Configurando firewall..."
ufw allow 80
ufw allow 443
ufw allow 22
ufw --force enable

# Parar containers existentes
print_status "Parando containers existentes..."
docker-compose down 2>/dev/null || true
docker stop websocket-wss-server 2>/dev/null || true
docker rm websocket-wss-server 2>/dev/null || true

# Criar docker-compose modificado para usar porta 8080
print_status "Criando configuração Docker para porta 8080..."
cat > docker-compose.nginx.yml << 'EOF'
version: '3.8'

services:
  websocket-wss:
    build: .
    container_name: websocket-wss-server
    ports:
      - "8080:8080"  # Usar porta 8080 em vez de 80
    environment:
      - DOMAIN=cubevisservice.site
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - websocket-network

networks:
  websocket-network:
    driver: bridge
EOF

# Modificar o Dockerfile para usar porta 8080
print_status "Modificando Dockerfile para porta 8080..."
sed -i 's/:80/:8080/g' Dockerfile
sed -i 's/:443/:8080/g' Dockerfile

# Fazer build da imagem
print_status "Fazendo build da imagem Docker WSS..."
docker-compose -f docker-compose.nginx.yml build --no-cache

if [ $? -eq 0 ]; then
    print_success "Build concluído com sucesso!"
else
    print_error "Erro no build da imagem Docker."
    exit 1
fi

# Executar container
print_status "Iniciando container WSS na porta 8080..."
docker-compose -f docker-compose.nginx.yml up -d

if [ $? -eq 0 ]; then
    print_success "Container WSS iniciado com sucesso!"
else
    print_error "Erro ao iniciar o container WSS."
    exit 1
fi

# Aguardar container ficar pronto
print_status "Aguardando container ficar pronto..."
sleep 10

# Verificar se o container está rodando
if docker ps | grep -q websocket-wss-server; then
    print_success "Container WSS está rodando!"
    
    # Mostrar informações
    echo ""
    echo "🌐 Informações do Servidor WSS:"
    echo "=============================="
    echo "URL: https://cubevisservice.site"
    echo "WebSocket: wss://cubevisservice.site/ws"
    echo "Container: websocket-wss-server (porta 8080)"
    echo "Proxy: Nginx (porta 80/443 → 8080)"
    echo "Certificados: /etc/letsencrypt/live/cubevisservice.site/"
    echo ""
    
    # Mostrar logs
    print_status "Últimas linhas dos logs:"
    docker logs --tail 10 websocket-wss-server
    
    echo ""
    print_success "🚀 Servidor WebSocket WSS está rodando com Nginx Proxy!"
    print_status "Para parar: docker-compose -f docker-compose.nginx.yml down"
    print_status "Para ver logs: docker-compose -f docker-compose.nginx.yml logs -f"
    print_status "Para reiniciar: docker-compose -f docker-compose.nginx.yml restart"
    
    # Testar conectividade
    print_status "Testando conectividade..."
    if curl -s -I https://cubevisservice.site | grep -q "200 OK"; then
        print_success "✅ HTTPS funcionando corretamente!"
    else
        print_warning "⚠️ HTTPS pode não estar funcionando ainda. Aguarde alguns minutos."
    fi
    
else
    print_error "Container não está rodando. Verificando logs..."
    docker logs websocket-wss-server
    exit 1
fi

echo ""
print_success "🎉 Deploy concluído com sucesso!"
print_status "Acesse: https://cubevisservice.site"
print_status "WebSocket: wss://cubevisservice.site/ws"
