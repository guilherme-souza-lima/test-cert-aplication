#!/bin/bash

# Script de configuração para WebSocket Seguro (WSS)
# Domínio: cubevisservice.site

echo "🔒 Configurando WebSocket Seguro (WSS) para cubevisservice.site"
echo "=============================================================="

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Atualizar sistema
echo "📦 Atualizando sistema..."
apt update && apt upgrade -y

# Instalar dependências
echo "🔧 Instalando dependências..."
apt install -y snapd nginx ufw

# Instalar Certbot
echo "🔐 Instalando Certbot..."
snap install core; snap refresh core
snap install --classic certbot
ln -sf /snap/bin/certbot /usr/bin/certbot

# Configurar firewall
echo "🔥 Configurando firewall..."
ufw allow 80
ufw allow 443
ufw allow 22
ufw --force enable

# Verificar DNS
echo "🌐 Verificando DNS..."
echo "Verificando se cubevisservice.site aponta para este servidor:"
nslookup cubevisservice.site

# Obter certificado SSL
echo "📜 Obtendo certificado SSL..."
read -p "Pressione Enter para continuar com a obtenção do certificado..."

# Tentar obter certificado
if certbot certonly --standalone -d cubevisservice.site --non-interactive --agree-tos --email admin@cubevisservice.site; then
    echo "✅ Certificado SSL obtido com sucesso!"
else
    echo "❌ Erro ao obter certificado SSL"
    echo "Verifique se:"
    echo "1. O domínio cubevisservice.site aponta para este servidor"
    echo "2. As portas 80 e 443 estão abertas"
    echo "3. Não há outros serviços usando a porta 80"
    exit 1
fi

# Configurar Nginx
echo "⚙️ Configurando Nginx..."
cat > /etc/nginx/sites-available/cubevisservice.site << 'EOF'
server {
    listen 80;
    server_name cubevisservice.site;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name cubevisservice.site;

    ssl_certificate /etc/letsencrypt/live/cubevisservice.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/cubevisservice.site/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

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

# Ativar site
ln -sf /etc/nginx/sites-available/cubevisservice.site /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Testar configuração Nginx
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "✅ Nginx configurado com sucesso!"
else
    echo "❌ Erro na configuração do Nginx"
    exit 1
fi

# Configurar renovação automática
echo "🔄 Configurando renovação automática..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && systemctl reload nginx") | crontab -

# Instalar Go (se não estiver instalado)
if ! command -v go &> /dev/null; then
    echo "📥 Instalando Go..."
    wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
    export PATH=$PATH:/usr/local/go/bin
fi

# Compilar aplicação
echo "🔨 Compilando aplicação WSS..."
cd /root
cp go_wss.mod go.mod
go mod tidy
go build -o websocket-wss wss_server.go

# Criar serviço systemd
echo "🚀 Criando serviço systemd..."
cat > /etc/systemd/system/websocket-wss.service << 'EOF'
[Unit]
Description=WebSocket Secure Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/root/websocket-wss
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Ativar e iniciar serviço
systemctl daemon-reload
systemctl enable websocket-wss
systemctl start websocket-wss

# Verificar status
echo "📊 Verificando status dos serviços..."
systemctl status websocket-wss --no-pager
systemctl status nginx --no-pager

echo ""
echo "🎉 Configuração concluída!"
echo "=========================="
echo "✅ Certificado SSL: /etc/letsencrypt/live/cubevisservice.site/"
echo "✅ Servidor WSS: https://cubevisservice.site"
echo "✅ WebSocket: wss://cubevisservice.site/ws"
echo "✅ Renovação automática: Configurada"
echo ""
echo "Para testar:"
echo "1. Acesse: https://cubevisservice.site"
echo "2. Verifique o certificado: https://www.ssllabs.com/ssltest/"
echo "3. Monitore logs: journalctl -u websocket-wss -f"
