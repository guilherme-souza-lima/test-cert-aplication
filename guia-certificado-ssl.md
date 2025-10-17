# Guia: Configuração de Certificado SSL com Certbot para cubevisservice.site

## Pré-requisitos
- Servidor Ubuntu/Debian com acesso root
- Domínio `cubevisservice.site` apontando para o IP do servidor
- Portas 80 e 443 liberadas no firewall

## Passo 1: Atualizar o Sistema
```bash
sudo apt update && sudo apt upgrade -y
```

## Passo 2: Instalar o Certbot
```bash
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

## Passo 3: Verificar se o domínio está apontando corretamente
```bash
nslookup cubevisservice.site
dig cubevisservice.site
```

## Passo 4: Configurar o Firewall (se necessário)
```bash
sudo ufw allow 80
sudo ufw allow 443
sudo ufw status
```

## Passo 5: Obter o Certificado SSL
```bash
# Para obter certificado com validação web (recomendado)
sudo certbot certonly --webroot -w /var/www/html -d cubevisservice.site

# OU se não tiver servidor web rodando, usar standalone
sudo certbot certonly --standalone -d cubevisservice.site
```

## Passo 6: Verificar se o certificado foi criado
```bash
sudo ls -la /etc/letsencrypt/live/cubevisservice.site/
```

## Passo 7: Configurar Renovação Automática
```bash
# Testar renovação
sudo certbot renew --dry-run

# Configurar cron para renovação automática
sudo crontab -e
# Adicionar esta linha:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

## Passo 8: Verificar Certificados
```bash
# Verificar certificado
sudo certbot certificates

# Verificar data de expiração
openssl x509 -in /etc/letsencrypt/live/cubevisservice.site/cert.pem -text -noout | grep "Not After"
```

## Passo 9: Configurar Nginx (Opcional - para proxy reverso)
```bash
# Instalar Nginx
sudo apt install nginx

# Criar configuração para o domínio
sudo nano /etc/nginx/sites-available/cubevisservice.site
```

### Conteúdo do arquivo de configuração Nginx:
```nginx
server {
    listen 80;
    server_name cubevisservice.site;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name cubevisservice.site;

    ssl_certificate /etc/letsencrypt/live/cubevisservice.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/cubevisservice.site/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Ativar o site
sudo ln -s /etc/nginx/sites-available/cubevisservice.site /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Passo 10: Testar o Certificado
```bash
# Testar SSL
curl -I https://cubevisservice.site

# Verificar certificado online
# Acesse: https://www.ssllabs.com/ssltest/analyze.html?d=cubevisservice.site
```

## Troubleshooting

### Erro: "Address already in use"
```bash
# Verificar o que está usando a porta 80
sudo netstat -tlnp | grep :80
sudo lsof -i :80

# Parar serviço conflitante
sudo systemctl stop apache2  # se estiver rodando
```

### Erro: "Domain validation failed"
- Verificar se o DNS está apontando corretamente
- Aguardar propagação DNS (pode levar até 24h)
- Verificar se não há firewall bloqueando

### Renovar certificado manualmente
```bash
sudo certbot renew
sudo systemctl reload nginx  # se usando nginx
```

## Arquivos Importantes
- **Certificado**: `/etc/letsencrypt/live/cubevisservice.site/cert.pem`
- **Chave Privada**: `/etc/letsencrypt/live/cubevisservice.site/privkey.pem`
- **Chain Completa**: `/etc/letsencrypt/live/cubevisservice.site/fullchain.pem`

## Próximos Passos
Após obter o certificado, você poderá:
1. Configurar o servidor Go para usar HTTPS/WSS
2. Atualizar o código para suportar conexões seguras
3. Testar a conexão WSS no navegador
