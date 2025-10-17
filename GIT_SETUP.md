# 📁 Configuração do Git - WebSocket WSS

## 🚀 Primeira Configuração

### 1. Inicializar Repositório
```bash
# Se ainda não foi inicializado
git init

# Adicionar todos os arquivos
git add .

# Fazer primeiro commit
git commit -m "feat: projeto WebSocket WSS com Docker configurado"
```

### 2. Configurar Repositório Remoto
```bash
# Adicionar repositório remoto (GitHub, GitLab, etc.)
git remote add origin https://github.com/seu-usuario/websocket-wss.git

# Ou se já existe
git remote set-url origin https://github.com/seu-usuario/websocket-wss.git
```

### 3. Fazer Push
```bash
# Push inicial
git push -u origin main

# Ou se for master
git push -u origin master
```

## 📋 Estrutura do Repositório

### ✅ Arquivos Incluídos no Git
```
websocket-wss/
├── .gitignore                 # Arquivos ignorados pelo Git
├── .dockerignore             # Arquivos ignorados pelo Docker
├── README.md                 # Documentação principal
├── GIT_SETUP.md             # Este arquivo
├── DEPLOY_PRODUCAO.md       # Guia de deploy em produção
├── DOCKER_SETUP.md          # Configuração Docker
├── RESUMO_WSS_DOCKER.md     # Resumo das configurações
├── guia-certificado-ssl.md  # Guia para certificados SSL
├── Dockerfile               # Container Docker WSS
├── docker-compose.yml       # Desenvolvimento
├── docker-compose.prod.yml  # Produção
├── deploy-wss-server.sh     # Script de deploy automático
├── build-and-run.sh         # Script de build local
├── setup_wss.sh            # Script de configuração SSL
├── main.go                  # Servidor local (HTTP/WS)
├── wss_server.go           # Servidor WSS (HTTPS/WSS)
├── client.go               # Cliente local
├── wss_client.go           # Cliente WSS
├── go.mod                  # Dependências Go
├── go_wss.mod             # Dependências WSS
└── go.sum                 # Checksums das dependências
```

### ❌ Arquivos Ignorados pelo Git
- Binários compilados (`websocket-server`, `websocket-wss`)
- Certificados SSL (`*.pem`, `*.key`, `*.crt`)
- Logs (`*.log`, `logs/`)
- Arquivos temporários (`*.tmp`, `*.temp`)
- Arquivos do sistema (`.DS_Store`, `Thumbs.db`)
- Arquivos de IDE (`.vscode/`, `.idea/`)
- Arquivos de configuração local (`.env*`)
- Arquivos de build (`build/`, `dist/`, `bin/`)

## 🔧 Comandos Git Úteis

### Desenvolvimento Diário
```bash
# Ver status dos arquivos
git status

# Adicionar arquivos modificados
git add .

# Fazer commit
git commit -m "feat: adicionar nova funcionalidade"

# Fazer push
git push origin main
```

### Gerenciamento de Branches
```bash
# Criar nova branch
git checkout -b feature/nova-funcionalidade

# Trocar de branch
git checkout main

# Fazer merge
git merge feature/nova-funcionalidade

# Deletar branch
git branch -d feature/nova-funcionalidade
```

### Atualizações
```bash
# Baixar atualizações
git pull origin main

# Ver histórico
git log --oneline

# Ver diferenças
git diff
```

## 🏷️ Tags e Releases

### Criar Tag de Versão
```bash
# Tag para versão
git tag -a v1.0.0 -m "Release v1.0.0 - WebSocket WSS com Docker"

# Push da tag
git push origin v1.0.0
```

### Criar Release no GitHub
1. Acesse o repositório no GitHub
2. Clique em "Releases"
3. Clique em "Create a new release"
4. Selecione a tag criada
5. Adicione descrição da versão
6. Publique o release

## 🔄 Workflow de Desenvolvimento

### 1. Desenvolvimento Local
```bash
# Criar branch para feature
git checkout -b feature/nova-funcionalidade

# Fazer alterações
# ... editar arquivos ...

# Commit das alterações
git add .
git commit -m "feat: implementar nova funcionalidade"

# Push da branch
git push origin feature/nova-funcionalidade
```

### 2. Deploy em Produção
```bash
# Fazer merge para main
git checkout main
git merge feature/nova-funcionalidade

# Push para produção
git push origin main

# Deploy no servidor
ssh root@seu-servidor
cd /opt/websocket-wss
git pull origin main
sudo ./deploy-wss-server.sh
```

## 🛠️ Configurações Recomendadas

### Git Config
```bash
# Configurar usuário
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"

# Configurar editor
git config --global core.editor "code --wait"

# Configurar branch padrão
git config --global init.defaultBranch main
```

### SSH Key (Recomendado)
```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "seu@email.com"

# Adicionar ao ssh-agent
ssh-add ~/.ssh/id_ed25519

# Copiar chave pública
cat ~/.ssh/id_ed25519.pub

# Adicionar no GitHub/GitLab
```

## 📝 Mensagens de Commit

### Padrão Recomendado
```
tipo: descrição breve

Descrição mais detalhada se necessário

- Item 1
- Item 2
- Item 3
```

### Tipos de Commit
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Documentação
- `style:` - Formatação
- `refactor:` - Refatoração
- `test:` - Testes
- `chore:` - Manutenção

### Exemplos
```bash
git commit -m "feat: adicionar suporte a WSS com certificados SSL"
git commit -m "fix: corrigir problema de conexão WebSocket"
git commit -m "docs: atualizar guia de deploy em produção"
git commit -m "chore: atualizar dependências do Docker"
```

## 🔍 Verificações Antes do Push

### Checklist
- [ ] Todos os arquivos estão commitados
- [ ] Mensagem de commit está clara
- [ ] Não há arquivos sensíveis (certificados, senhas)
- [ ] Documentação está atualizada
- [ ] Testes passaram (se houver)
- [ ] Build do Docker funciona

### Comandos de Verificação
```bash
# Ver arquivos não rastreados
git status

# Ver diferenças
git diff --cached

# Ver histórico
git log --oneline -5

# Testar build Docker
docker-compose build
```

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. Arquivo muito grande
```bash
# Ver arquivos grandes
git ls-files | xargs ls -la | sort -k5 -rn | head

# Remover do cache
git rm --cached arquivo-grande
echo "arquivo-grande" >> .gitignore
```

#### 2. Commit acidental de arquivo sensível
```bash
# Remover do histórico
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch arquivo-sensivel' --prune-empty --tag-name-filter cat -- --all

# Force push
git push origin --force --all
```

#### 3. Conflitos de merge
```bash
# Ver conflitos
git status

# Resolver conflitos manualmente
# ... editar arquivos ...

# Adicionar arquivos resolvidos
git add arquivo-resolvido

# Finalizar merge
git commit
```

## 🎯 Próximos Passos

1. **Configurar repositório remoto** - GitHub, GitLab, etc.
2. **Fazer push inicial** - Enviar código para o repositório
3. **Configurar CI/CD** - GitHub Actions, GitLab CI, etc.
4. **Configurar webhooks** - Deploy automático
5. **Documentar APIs** - Swagger, OpenAPI, etc.

## ✅ Resultado Final

Após configurar o Git, você terá:
- ✅ Repositório versionado e organizado
- ✅ Histórico de alterações completo
- ✅ Colaboração facilitada
- ✅ Deploy automatizado
- ✅ Backup do código
- ✅ Controle de versões
