#!/bin/bash

# Script para configurar Nginx como proxy reverso para WebSocket WSS
# Execute no servidor: sudo ./nginx-proxy-config.sh

echo "🔧 Configurando Nginx como Proxy Reverso para WebSocket WSS"
echo "============================================================="

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

# Verificar se Nginx está instalado
if ! command -v nginx &> /dev/null; then
    print_error "Nginx não está instalado!"
    exit 1
fi

print_success "Nginx encontrado!"

# Backup da configuração atual (apenas para segurança)
print_status "Fazendo backup da configuração do Nginx..."
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)

# Verificar se o site já existe
if [ -f "/etc/nginx/sites-available/cubevisservice.site" ]; then
    print_warning "Configuração para cubevisservice.site já existe!"
    read -p "Sobrescrever? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Mantendo configuração existente."
        exit 0
    fi
fi

# Criar configuração para o domínio
print_status "Criando configuração para cubevisservice.site..."

cat > /etc/nginx/sites-available/cubevisservice.site << 'EOF'
server {
    listen 80;
    server_name cubevisservice.site;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name cubevisservice.site;

    # Certificados SSL (serão configurados pelo Certbot)
    ssl_certificate /etc/letsencrypt/live/cubevisservice.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/cubevisservice.site/privkey.pem;
    
    # Configurações SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Proxy para o container Docker
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
}
EOF

# Ativar o site
print_status "Ativando configuração do site..."
ln -sf /etc/nginx/sites-available/cubevisservice.site /etc/nginx/sites-enabled/

# Testar configuração
print_status "Testando configuração do Nginx..."
nginx -t

if [ $? -eq 0 ]; then
    print_success "Configuração do Nginx válida!"
    
    # Recarregar Nginx
    print_status "Recarregando Nginx..."
    systemctl reload nginx
    
    print_success "Nginx configurado como proxy reverso!"
    print_status "Agora execute: sudo ./deploy-wss-server-nginx.sh"
else
    print_error "Erro na configuração do Nginx!"
    print_status "Restaurando backup..."
    cp /etc/nginx/nginx.conf.backup.* /etc/nginx/nginx.conf
    exit 1
fi
