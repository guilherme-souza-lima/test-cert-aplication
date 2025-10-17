# Dockerfile para WebSocket Server
# Porta: 5678

# Estágio 1: Build
FROM golang:1.21-alpine AS builder

# Instalar dependências necessárias
RUN apk add --no-cache git ca-certificates tzdata

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências
COPY go.mod go.sum ./

# Baixar dependências
RUN go mod download

# Copiar código fonte WSS
COPY wss/ ./

# Compilar aplicação WSS
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o websocket-wss wss_server.go

# Estágio 2: Runtime
FROM alpine:latest

# Instalar ca-certificates para HTTPS
RUN apk --no-cache add ca-certificates tzdata

# Criar usuário não-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Definir diretório de trabalho
WORKDIR /app

# Copiar binário compilado
COPY --from=builder /app/websocket-wss .

# Copiar arquivos de configuração
COPY go.mod go.sum ./

# Alterar propriedade dos arquivos
RUN chown -R appuser:appgroup /app

# Mudar para usuário não-root
USER appuser

# Expor portas 80 e 443 para WSS
EXPOSE 80 443

# Health check para HTTPS
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider https://localhost/ || exit 1

# Comando para executar a aplicação WSS
CMD ["./websocket-wss"]
