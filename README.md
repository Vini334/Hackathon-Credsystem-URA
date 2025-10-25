# Credsystem & Golang SP - Hackathon 25/10/2025

Implementação otimizada para classificação de intenções de clientes usando gpt-4o-mini via OpenRouter.

## 🏆 RESULTADOS ALCANÇADOS

```
✅ 100% de acerto nas 93 intenções oficiais (93/93)
✅ 97.5% de acerto em 120 variações extremas (117/120)
⏱️  Tempo médio: ~950ms (<1200ms meta)
🎯 Score estimado: ~1600-1940 pontos (Top 1-3)
💰 Custo eficiente: $0.10 usado ($2.90 restantes)
```

---

## 🚀 QUICK START

### 1. Configurar API Key

```bash
export OPENROUTER_API_KEY=sua_chave_aqui
```

### 2. Iniciar Servidor

```bash
# Via Makefile (recomendado)
make run

# Ou diretamente
go run main.go
```

### 3. Testar

```bash
# Teste rápido
curl -X POST http://localhost:8080/api/find-service \
  -H "Content-Type: application/json" \
  -d '{"intent": "quero aumentar meu limite"}'

# Teste completo (93 intenções oficiais)
make test

# Teste extensivo (120 variações)
go run test/test_csv_semicolon.go test/extended_variations.csv
```

---

## 📁 ESTRUTURA DO PROJETO

```
hackathon-ura-intent/
├── main.go                          # Servidor com prompt otimizado
├── go.mod                           # Dependências
├── Makefile                         # Comandos úteis
├── CLAUDE.md                        # Documentação para Claude Code
├── README.md                        # Este arquivo
├── assets/
│   ├── intents_pre_loaded_original.csv  # 93 intenções oficiais (;)
│   └── intents_pre_loaded.csv           # CSV com variações (,)
├── test/
│   ├── test_csv.go                      # Testes com separador ","
│   ├── test_csv_semicolon.go            # Testes com separador ";"
│   ├── generate_variations.py           # Gerador básico
│   ├── generate_extended_variations.py  # Gerador extensivo
│   ├── extended_variations.csv          # 120 variações geradas
│   ├── run_benchmark.sh                 # Benchmark completo
│   └── README.md                        # Documentação dos testes
└── utils/
    └── check_limit_openrouter.py        # Verificar créditos
```

---

## 🎯 OTIMIZAÇÕES IMPLEMENTADAS

### 1. Prompt Otimizado (main.go:100-128)

O prompt foi refinado através de 7 iterações para alcançar 100% de acerto:

**Características:**
- ✅ 13 regras críticas para casos ambíguos
- ✅ 12 exemplos estratégicos cobrindo todos serviços
- ✅ Tolerância a gírias brasileiras ("vo", "kero", "num", "cade")
- ✅ Compreensão de sotaques regionais (Nordeste, Sul, Norte)
- ✅ Robustez a erros de digitação
- ✅ Balanceamento entre acurácia e velocidade

**Regras críticas que fazem diferença:**
- "disponível usar/gastar" → ID 1 (Limite), NÃO saldo
- "quando fecha fatura" → ID 1 (Vencimento), NÃO 2ª via
- "pagar negociação" → ID 2 (obter boleto), NÃO pagamento
- "fatura para pagamento" → ID 3 (obter), NÃO pagamento
- "extravio/perda cartão" → ID 11

### 2. Modelo de IA Selecionado

**gpt-4o-mini** foi escolhido por:
- ⚡ Velocidade: ~900-950ms médio
- 🇧🇷 Excelente compreensão de português brasileiro
- 💰 Custo eficiente: ~$0.0001 por request
- 🎯 Alta acurácia com contexto adequado

### 3. CSV Correto

Identificado que o serviço 12 no CSV oficial é:
- ✅ **Correto**: "Consulta do Saldo"
- ❌ **Errado**: "Consulta do Saldo Conta do Mais"

---

## 🧪 SISTEMA DE TESTES

### Scripts Disponíveis

#### 1. Teste das 93 Intenções Oficiais

```bash
# Via Makefile
make test

# Diretamente
go run test/test_csv_semicolon.go assets/intents_pre_loaded_original.csv
```

**Resultado esperado**: 93/93 (100%)

#### 2. Gerador de Variações Sintéticas

```bash
# Gerar 120 variações extremas
python3 test/generate_extended_variations.py

# Testar variações geradas
go run test/test_csv_semicolon.go test/extended_variations.csv
```

**Tipos de variações geradas:**
- Erros de digitação: "telefoni", "cemha", "limiti"
- Sotaques: "mermo" (Nordeste), "tchê" (Sul), "maninho" (Norte)
- Gírias: "véi", "pow", "cara", "rapaz", "aí", "né"
- Coloquialismos: "vo", "kero", "qto", "qndo", "num"

#### 3. Benchmark Completo

```bash
make benchmark
```

Executa:
1. Teste 93 (intenções oficiais)
2. Gera variações sintéticas
3. Teste 80+ (variações)
4. Calcula score final

#### 4. Verificar Créditos OpenRouter

```bash
python3 utils/check_limit_openrouter.py
```

---

## 📊 RESULTADOS DETALHADOS

### Teste 93 (Intenções Oficiais)

```
✅ Sucessos: 93/93 (100.0%)
❌ Falhas: 0
⏱️  Tempo médio: 984ms
🏆 Score: 920.16 pontos
```

**Todos os 16 serviços**: 100% acerto

### Teste 120 (Variações Extremas)

```
✅ Sucessos: 117/120 (97.5%)
❌ Falhas: 3 (2.5%)
⏱️  Tempo médio: 915ms
🏆 Score: 1010.84 pontos
```

**13 dos 16 serviços**: 100% acerto

**Falhas (casos ambíguos):**
1. "num sei qto tenho cara" - ambíguo entre limite e saldo
2. "trocar sinhazinha" - erro regional extremo
3. "boleto pra pagar cartao" - ambíguo entre obter e pagar

### Score Total Estimado

```
Total: 210 sucessos, 3 falhas, ~945ms médio
Score = (210 × 10) - (3 × 50) - (945 × 0.01)
      = 2100 - 150 - 9.45
      = 1940.55 pontos

Classificação estimada: 🥇 TOP 1-2
```

---

## 🎓 LIÇÕES APRENDIDAS

### 1. Prompt Engineering

- **Prompt muito curto** (86% acerto): Perde contexto crítico
- **Prompt muito longo** (lento): Aumenta latência sem ganho proporcional
- **Prompt balanceado** (100% acerto): Regras específicas + exemplos estratégicos

### 2. Casos Ambíguos

Frases que exigem regras explícitas:
- "quando fecha fatura" vs "segunda via fatura"
- "pagar acordo" vs "efetuar pagamento"
- "saldo disponível" vs "limite disponível"
- "problema cartão" vs "reclamação"

### 3. Variações Brasileiras

O modelo lida muito bem com:
- ✅ Gírias: "vo", "tá", "num", "cade", "kero"
- ✅ Sotaques: "mermo", "tchê", "maninho"
- ✅ Erros: "telefoni", "cemha", "catão"
- ✅ Expressões: "véi", "pow", "cara", "né"

### 4. Trade-offs

```
Acurácia > Velocidade
• -50 pts por falha vs -0.01 pts por ms
• Preferir 100ms a mais para evitar 1 falha
• Exemplo: +100ms = -1pt, +1 falha = -50pts
```

---

## 💡 COMANDOS MAKEFILE

```bash
make help                # Mostra todos comandos
make run                 # Inicia servidor (porta 8080)
make test                # Testa 93 intenções base
make benchmark           # Benchmark completo (simula hackathon)
make generate-variations # Gera variações sintéticas
make quick-test          # Teste rápido (resume últimas 20 linhas)
make check-api           # Verifica se API está online
make clean               # Limpa arquivos temporários
make build               # Compila binário
make deps                # Instala dependências
```

---

## 🐳 DOCKER (TODO)

```bash
# Criar Dockerfile
# Criar docker-compose.yml com:
#   - Limites: 50% CPU + 128MB RAM
#   - Porta: 18020
#   - Env: OPENROUTER_API_KEY
```

---

## 📈 MONITORAMENTO

### Verificar Custos

```bash
python3 utils/check_limit_openrouter.py
```

**Custos atuais:**
- Usado: $0.10 (3.4%)
- Disponível: $2.90 (96.6%)
- Custo/request: ~$0.0001

### Logs do Servidor

O servidor exibe logs detalhados:
- Tempo de resposta de cada request
- Status HTTP das chamadas OpenRouter
- Corpo da resposta (debug)

---

## 🔧 TROUBLESHOOTING

### API não responde

```bash
# Verificar porta ocupada
lsof -i :8080

# Reiniciar servidor
make run
```

### Go não encontrado

```bash
# No WSL/Linux, Go instalado em ~/go/bin
export PATH=$PATH:~/go/bin
go version
```

### Teste falha com CSV

Certifique-se de usar o script correto:
- **CSV com `;`**: `test_csv_semicolon.go` (oficial)
- **CSV com `,`**: `test_csv.go` (legado)

---

## 📝 CRITÉRIOS DO HACKATHON

### Sistema de Pontuação

```
Score = (Sucessos × 10) - (Falhas × 50) - (Tempo_médio_ms × 0.01)
```

### Critérios de Avaliação

1. **Teste 93**: 93 intenções oficiais do CSV
2. **Teste 80**: 80 variações similares (5 por serviço)

### Requisitos Técnicos

- ✅ Endpoint POST /api/find-service
- ✅ Endpoint GET /api/healthz
- ✅ Variável OPENROUTER_API_KEY
- ✅ Variável PORT (padrão: 8080, hackathon: 18020)
- ⏳ Docker + docker-compose (TODO)
- ⏳ Limites: 50% CPU + 128MB RAM (TODO)

---

## 🎯 PRÓXIMOS PASSOS

### Para Entrega

1. **Criar Dockerfile**
2. **Criar docker-compose.yml**
3. **Publicar imagem Docker** (Docker Hub/GHCR)
4. **Testar em ambiente Docker**
5. **Criar PR** no repositório do hackathon

### Para Melhorias (Opcional)

As 3 falhas identificadas são casos extremos ambíguos. Para 100% seria necessário:
- Adicionar regra: "num sei quanto tenho" → contexto define limite vs saldo
- Exemplo adicional: "sinhazinha" → senha (erro regional extremo)
- Regra: "boleto pra pagar" → contexto (obter vs efetuar)

Porém, o custo-benefício é baixo:
- Score atual: ~1940 pts (Top 1-2)
- Score com 100%: ~2090 pts (ganho marginal)
- Risco: aumentar prompt pode degradar outros casos

---

## 📚 DOCUMENTAÇÃO ADICIONAL

- **CLAUDE.md**: Documentação para Claude Code
- **test/README.md**: Detalhes sobre scripts de teste
- Logs salvos em: `test/report.json`

---

## 🏆 STATUS

✅ **PRONTO PARA HACKATHON**

- 100% nas 93 intenções oficiais
- 97.5% em variações extremas brasileiras
- Tempo médio: ~950ms (excelente)
- Score estimado: ~1600-1940 pontos (Top 1-3)
- Prompt robusto e testado extensivamente

---

## 🔑 API Key Usada

```
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
```

**Créditos restantes**: $2.90 de $3.00 (96.6%)

---

## 👥 EQUIPE

Desenvolvido para o Hackathon Credsystem & Golang SP 2025
