# WebSocket - Números Aleatórios

Um servidor WebSocket simples em Go que envia números aleatórios para clientes conectados.

## 🔒 Versão Segura (WSS)

Este projeto inclui suporte para WebSocket Secure (WSS) com certificados SSL para o domínio `cubevisservice.site`.

## Funcionalidades

- Servidor WebSocket que envia números aleatórios a cada segundo
- Interface web simples para testar a conexão
- Suporte a múltiplos clientes conectados simultaneamente
- **WebSocket Secure (WSS)** com certificados SSL
- Redirecionamento automático HTTP → HTTPS
- Renovação automática de certificados

## Como executar

### 🐳 Docker (Desenvolvimento)

1. **Execução rápida com Docker Compose:**
```bash
docker-compose up -d
```

2. **Ou use o script automatizado:**
```bash
./build-and-run.sh
```

3. **Acesse:** http://localhost:5678

### 🚀 Docker WSS (Produção)

1. **Deploy automático no servidor:**
```bash
sudo ./deploy-wss-server.sh
```

2. **Ou deploy manual:**
```bash
# Obter certificado SSL
sudo certbot certonly --standalone -d cubevisservice.site

# Executar com docker-compose de produção
docker-compose -f docker-compose.prod.yml up -d
```

3. **Acesse:** https://cubevisservice.site

### Versão Local (HTTP/WS)

1. Execute o servidor local:
```bash
./run-local.sh
```

2. Ou execute manualmente:
```bash
cd local
go mod tidy
go run main.go
```

3. Abra seu navegador em: http://localhost:5678

### Versão Segura (HTTPS/WSS) - Produção

1. **Configure o certificado SSL** (veja `guia-certificado-ssl.md`):
```bash
# Execute o script de configuração automática
sudo chmod +x setup_wss.sh
sudo ./setup_wss.sh
```

2. **Ou configure manualmente** seguindo o guia detalhado em `guia-certificado-ssl.md`

3. **Execute o servidor WSS**:
```bash
./run-wss.sh
```

Ou execute manualmente:
```bash
cd wss
go mod tidy
go run wss_server.go
```

4. **Acesse**: https://cubevisservice.site

## Como usar

### Docker Desenvolvimento
- Acesse http://localhost:5678 para ver a interface web
- O WebSocket estará disponível em ws://localhost:5678/ws
- Container otimizado para desenvolvimento

### Docker WSS Produção
- Acesse https://cubevisservice.site para ver a interface web
- O WebSocket estará disponível em wss://cubevisservice.site/ws
- Container com certificados SSL e pronto para produção

### Versão Local
- Acesse http://localhost:5678 para ver a interface web
- O WebSocket estará disponível em ws://localhost:5678/ws
- Os números aleatórios aparecerão automaticamente na página

### Versão Segura (Produção)
- Acesse https://cubevisservice.site para ver a interface web
- O WebSocket estará disponível em wss://cubevisservice.site/ws
- Conexão criptografada e segura

### Testando via linha de comando

**Para versão local:**
```bash
cd local
go run client.go
```

**Para versão segura:**
```bash
cd wss
go run wss_client.go
```

Os clientes irão conectar ao servidor e exibir os números aleatórios recebidos no terminal.

## Estrutura do projeto

### 📁 Arquivos Principais
- `local/main.go` - Servidor WebSocket local (HTTP/WS) - Porta 5678
- `wss/wss_server.go` - Servidor WebSocket seguro (HTTPS/WSS)
- `local/client.go` - Cliente de teste para versão local
- `wss/wss_client.go` - Cliente de teste para versão segura

### 🐳 Docker
- `Dockerfile` - Configuração do container Docker (WSS)
- `docker-compose.yml` - Orquestração para desenvolvimento
- `docker-compose.prod.yml` - Orquestração para produção
- `build-and-run.sh` - Script automatizado de build e execução
- `deploy-wss-server.sh` - Script de deploy para servidor WSS
- `.dockerignore` - Arquivos ignorados no build Docker

### 📚 Documentação e Configuração
- `setup_wss.sh` - Script de configuração automática para WSS
- `guia-certificado-ssl.md` - Guia detalhado para configurar SSL
- `go.mod` / `go_wss.mod` - Gerenciamento de dependências
- `README.md` - Este arquivo

## Dependências

- `github.com/gorilla/websocket` - Biblioteca para WebSocket em Go
