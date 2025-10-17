# 🚀 Deploy em Produção - WebSocket WSS

## 📋 Pré-requisitos do Servidor

### Sistema Operacional
- Ubuntu 20.04+ ou Debian 11+
- Acesso root ou sudo
- Pelo menos 1GB RAM
- 10GB espaço em disco

### Configuração de Rede
- Domínio `cubevisservice.site` apontando para o IP do servidor
- Portas 80 e 443 liberadas no firewall
- Acesso SSH configurado

## 🔧 Deploy Automático (Recomendado)

### 1. Preparar o Servidor
```bash
# Conectar via SSH
ssh root@seu-servidor

# Atualizar sistema
apt update && apt upgrade -y

# Instalar dependências básicas
apt install -y curl wget git
```

### 2. Transferir Arquivos
```bash
# Clonar ou transferir o projeto
git clone <seu-repositorio> /opt/websocket-wss
cd /opt/websocket-wss

# Ou transferir via SCP
scp -r ./wss root@seu-servidor:/opt/websocket-wss
```

### 3. Executar Deploy
```bash
cd /opt/websocket-wss
chmod +x deploy-wss-server.sh
sudo ./deploy-wss-server.sh
```

## 🔧 Deploy Manual

### 1. Instalar Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker
```

### 2. Instalar Docker Compose
```bash
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 3. Obter Certificado SSL
```bash
# Instalar Certbot
snap install core; snap refresh core
snap install --classic certbot

# Obter certificado
certbot certonly --standalone -d cubevisservice.site
```

### 4. Executar Container
```bash
# Build da imagem
docker-compose -f docker-compose.prod.yml build

# Executar em produção
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Verificação do Deploy

### 1. Testar HTTP/HTTPS
```bash
# Testar redirecionamento HTTP → HTTPS
curl -I http://cubevisservice.site

# Testar HTTPS
curl -I https://cubevisservice.site
```

### 2. Testar WebSocket WSS
```bash
# Instalar wscat para teste
npm install -g wscat

# Testar conexão WSS
wscat -c wss://cubevisservice.site/ws
```

### 3. Verificar Logs
```bash
# Ver logs do container
docker-compose logs -f websocket-wss

# Ver logs do sistema
journalctl -u docker
```

## 🔧 Gerenciamento

### Comandos Úteis
```bash
# Status dos containers
docker-compose ps

# Parar serviço
docker-compose down

# Reiniciar serviço
docker-compose restart

# Atualizar serviço
docker-compose pull
docker-compose up -d

# Ver logs em tempo real
docker-compose logs -f
```

### Backup dos Certificados
```bash
# Backup dos certificados SSL
tar -czf ssl-backup-$(date +%Y%m%d).tar.gz /etc/letsencrypt/
```

### Monitoramento
```bash
# Verificar uso de recursos
docker stats websocket-wss-server

# Verificar saúde do container
docker inspect websocket-wss-server | grep Health -A 10
```

## 🔄 Renovação Automática

### Configurar Cron
```bash
# Editar crontab
crontab -e

# Adicionar linha para renovação automática
0 12 * * * /usr/bin/certbot renew --quiet && docker-compose restart websocket-wss
```

### Verificar Renovação
```bash
# Testar renovação
certbot renew --dry-run

# Verificar data de expiração
openssl x509 -in /etc/letsencrypt/live/cubevisservice.site/cert.pem -text -noout | grep "Not After"
```

## 🛠️ Troubleshooting

### Problemas Comuns

#### 1. Container não inicia
```bash
# Verificar logs
docker logs websocket-wss-server

# Verificar se as portas estão livres
netstat -tlnp | grep :80
netstat -tlnp | grep :443
```

#### 2. Certificado SSL não funciona
```bash
# Verificar se o certificado existe
ls -la /etc/letsencrypt/live/cubevisservice.site/

# Verificar permissões
ls -la /etc/letsencrypt/live/cubevisservice.site/
```

#### 3. WebSocket não conecta
```bash
# Verificar se o container está rodando
docker ps | grep websocket

# Testar conectividade
telnet cubevisservice.site 443
```

### Logs Importantes
```bash
# Logs do Docker
journalctl -u docker

# Logs do container
docker logs websocket-wss-server

# Logs do sistema
tail -f /var/log/syslog
```

## 📊 Monitoramento

### Métricas Importantes
- **CPU**: Deve estar abaixo de 50%
- **RAM**: Deve estar abaixo de 512MB
- **Conexões**: Monitorar número de clientes conectados
- **Certificado**: Verificar data de expiração

### Alertas Recomendados
- Container parado
- Certificado expirando em 30 dias
- Uso de CPU > 80%
- Uso de RAM > 90%

## 🔒 Segurança

### Configurações de Segurança
- Container roda com usuário não-root
- Certificados SSL válidos
- Firewall configurado
- Logs rotacionados
- Renovação automática de certificados

### Backup
- Certificados SSL
- Configurações do Docker
- Logs importantes
- Código da aplicação

## 🎯 Resultado Final

Após o deploy, você terá:
- ✅ WebSocket WSS funcionando em https://cubevisservice.site
- ✅ Certificado SSL válido e renovação automática
- ✅ Container Docker otimizado e seguro
- ✅ Monitoramento e logs configurados
- ✅ Sistema pronto para produção
