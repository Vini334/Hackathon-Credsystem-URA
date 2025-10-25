# Scripts de Teste e Benchmark

Este diretório contém ferramentas para testar e validar o desempenho do serviço de classificação de intenções.

## 🎯 Objetivo

Simular as condições do hackathon com duas rodadas de testes:
1. **Teste 93**: Validar as 93 intenções base do CSV
2. **Teste 80**: Testar com variações sintéticas (simulando os testes secretos)

## 📁 Arquivos

- **test_csv.go**: Script principal de teste que valida intenções do CSV
- **generate_variations.py**: Gerador de variações sintéticas para simular sotaques, erros e coloquialismos
- **run_benchmark.sh**: Benchmark completo simulando o ambiente do hackathon

## 🚀 Uso Rápido

### 1. Testar com as 93 intenções base

```bash
# Via Makefile (recomendado)
make test

# Ou diretamente
go run test/test_csv.go assets/intents_pre_loaded.csv
```

### 2. Gerar variações sintéticas

```bash
# Via Makefile
make generate-variations

# Ou diretamente (5 variações por serviço)
python3 test/generate_variations.py
```

### 3. Executar benchmark completo

```bash
# Via Makefile
make benchmark

# Ou diretamente
chmod +x test/run_benchmark.sh
./test/run_benchmark.sh
```

## 📊 Entendendo os Resultados

### Score do Hackathon

O score é calculado usando a fórmula oficial:

```
Score = (Sucessos × 10.0) - (Falhas × 50.0) - (Tempo_Médio_ms × 0.01)
```

**Exemplo:**
- 171 sucessos → +1710 pts
- 2 falhas → -100 pts
- 3270ms tempo médio → -32.7 pts
- **Score final: 1577.3 pontos**

### Interpretação

- ✅ **Score > 1500**: Excelente! Alta taxa de acerto e tempo bom
- ⚠️ **Score 1000-1500**: Bom, mas há espaço para melhorias
- ⚠️ **Score 500-1000**: Precisa otimizar (muitas falhas ou tempo alto)
- ❌ **Score < 500**: Crítico - revisar implementação urgentemente

## 🔧 Scripts Detalhados

### test_csv.go

Script Go que lê um CSV e testa cada intenção contra a API.

**Uso:**
```bash
go run test/test_csv.go [caminho-do-csv]

# Com URL customizada
API_URL=http://localhost:3000 go run test/test_csv.go assets/intents_pre_loaded.csv
```

**Saída:**
- Progresso linha por linha
- Relatório final com acurácia e tempo
- Arquivo JSON detalhado: `test/report.json`

### generate_variations.py

Gera variações sintéticas aplicando:
- Transformações coloquiais ("vou" → "vo", "quero" → "kero")
- Erros de digitação/transcrição
- Gírias brasileiras ("né", "cara", "mano")
- Remoção de pontuação
- Sotaques regionais

**Uso:**
```bash
python3 test/generate_variations.py [input_csv] [output_csv] [num_variações]

# Exemplo: 5 variações por serviço
python3 test/generate_variations.py assets/intents_pre_loaded.csv test/synthetic_variations.csv 5
```

**Exemplos de Variações Geradas:**
```
Original: "Quero cancelar meu cartão"
Variações:
  - "vo cancela meo cartao"
  - "kero cancelar o cartao, né"
  - "cancela meu cartao pra mim"
  - "num quero mais o cartao"
  - "quero cancela esse cartao"
```

### run_benchmark.sh

Script completo que:
1. Verifica se API está online
2. Gera variações sintéticas
3. Executa Rodada 1 (93 intenções base)
4. Executa Rodada 2 (variações sintéticas)
5. Calcula score final
6. Fornece recomendações

**Pré-requisitos:**
```bash
export OPENROUTER_API_KEY=seu_token_aqui
```

**Saída:**
```
🏆 HACKATHON BENCHMARK - Credsystem & Golang SP
================================================

Rodada 1 (93 testes base):
  ✅ Sucessos: 91
  ❌ Falhas: 2
  ⏱️  Tempo médio: 450ms

Rodada 2 (variações sintéticas):
  ✅ Sucessos: 78
  ❌ Falhas: 2
  ⏱️  Tempo médio: 480ms

🏆 SCORE FINAL: 1581.35 pontos
```

## 💡 Dicas de Otimização

### Para Aumentar Acurácia
1. Melhore o prompt em `main.go:101-130`
2. Adicione mais exemplos de variações no prompt
3. Teste diferentes modelos (gpt-4o-mini vs mistral-7b)

### Para Reduzir Tempo
1. Use modelos mais rápidos
2. Reduza tamanho do prompt
3. Implemente cache de respostas comuns
4. Otimize timeout (atualmente 8s)

### Para Melhorar Score
- **Priorize acurácia**: -50 pts por falha vs -0.01 por ms
- **Exemplo**: Preferível ter 500ms a mais e evitar 1 falha
  - +50ms = -0.5 pts
  - +1 falha = -50 pts

## 🐛 Troubleshooting

### API não responde
```bash
# Verificar se porta está ocupada
lsof -i :8080

# Iniciar servidor
make run
```

### Python não encontrado
```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3
```

### Erro de permissão no script
```bash
chmod +x test/run_benchmark.sh
```

## 📈 Monitoramento Contínuo

Durante desenvolvimento:

```bash
# Terminal 1: Servidor
make run

# Terminal 2: Testes contínuos
watch -n 30 'make quick-test'
```

## 🎯 Checklist Pré-Submissão

- [ ] Score > 1500 pontos no benchmark
- [ ] Taxa de acerto > 95% nas 93 intenções base
- [ ] Tempo médio < 500ms
- [ ] Zero erros HTTP/timeouts
- [ ] Testado com variações coloquiais
- [ ] Logs limpos sem warnings críticos
