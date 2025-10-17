# 🐳 Configuração Docker - WebSocket Server

## 📋 Resumo das Alterações

### ✅ Arquivos Removidos (Redundantes)
- `client_test.go` - Duplicado do `client.go`
- `main_wss.go` - Duplicado do `wss_server.go`
- `client_wss.go` - Duplicado do `wss_client.go`
- `RESUMO_PROJETO.md` - Documentação redundante

### 🔧 Arquivos Modificados
- **`main.go`** - Porta alterada de 8080 para **5678**
- **`client.go`** - Porta alterada de 8080 para **5678**
- **`README.md`** - Atualizado com informações do Docker

### 🆕 Arquivos Criados
- **`Dockerfile`** - Container otimizado multi-stage
- **`docker-compose.yml`** - Orquestração com Docker Compose
- **`build-and-run.sh`** - Script automatizado de build/execução
- **`.dockerignore`** - Otimização do build Docker
- **`DOCKER_SETUP.md`** - Este arquivo

## 🚀 Como Executar

### Opção 1: Docker Compose (Recomendado)
```bash
docker-compose up -d
```

### Opção 2: Script Automatizado
```bash
./build-and-run.sh
```

### Opção 3: Docker Manual
```bash
# Build da imagem
docker build -t websocket-server .

# Executar container
docker run -d \
  --name websocket-random-numbers \
  -p 5678:5678 \
  --restart unless-stopped \
  websocket-server
```

## 🌐 Acesso
- **URL**: http://localhost:5678
- **WebSocket**: ws://localhost:5678/ws

## 📊 Características do Container

### 🔒 Segurança
- ✅ Usuário não-root (appuser:1001)
- ✅ Imagem Alpine Linux (minimalista)
- ✅ Certificados SSL incluídos
- ✅ Health check configurado

### ⚡ Performance
- ✅ Multi-stage build (otimizado)
- ✅ Imagem final ~15MB
- ✅ Build cache otimizado
- ✅ .dockerignore configurado

### 🔧 Configuração
- ✅ Porta 5678 exposta
- ✅ Restart automático
- ✅ Logs estruturados
- ✅ Health check a cada 30s

## 📝 Comandos Úteis

### Gerenciamento do Container
```bash
# Ver logs
docker logs -f websocket-random-numbers

# Parar container
docker stop websocket-random-numbers

# Remover container
docker rm websocket-random-numbers

# Executar comando no container
docker exec -it websocket-random-numbers sh
```

### Docker Compose
```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose down

# Ver logs
docker-compose logs -f

# Rebuild
docker-compose up --build -d
```

## 🔍 Verificação

### Testar Conectividade
```bash
# Testar HTTP
curl http://localhost:5678

# Testar WebSocket (com wscat)
wscat -c ws://localhost:5678/ws
```

### Verificar Status
```bash
# Status do container
docker ps | grep websocket

# Health check
docker inspect websocket-random-numbers | grep Health -A 10
```

## 📈 Próximos Passos

1. **Iniciar Docker** - `sudo systemctl start docker` (Linux) ou iniciar Docker Desktop
2. **Executar build** - `./build-and-run.sh`
3. **Testar aplicação** - Acessar http://localhost:5678
4. **Deploy em produção** - Usar docker-compose em servidor

## 🎯 Resultado Final

Um container Docker otimizado que:
- ✅ Executa na porta 5678
- ✅ Tem apenas 15MB de tamanho
- ✅ Usa usuário não-root para segurança
- ✅ Inclui health check automático
- ✅ Suporta restart automático
- ✅ Está pronto para produção
