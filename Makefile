.PHONY: run test benchmark generate-variations help

# Configurações
API_PORT ?= 8080
export PORT=$(API_PORT)

help: ## Mostra esta ajuda
	@echo "Comandos disponíveis:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

run: ## Inicia o servidor na porta 8080 (ou PORT)
	@echo "🚀 Iniciando servidor na porta $(PORT)..."
	go run main.go

build: ## Compila o binário
	@echo "🔨 Compilando..."
	go build -o bin/ura-intent main.go
	@echo "✅ Binário criado em bin/ura-intent"

test: ## Roda testes com as 93 intenções base
	@echo "🧪 Testando 93 intenções base..."
	@go run test/test_csv.go assets/intents_pre_loaded.csv

generate-variations: ## Gera variações sintéticas para testes
	@echo "🔄 Gerando variações sintéticas..."
	@python3 test/generate_variations.py

benchmark: ## Roda benchmark completo (simula hackathon)
	@echo "🏆 Executando benchmark completo..."
	@chmod +x test/run_benchmark.sh
	@./test/run_benchmark.sh

quick-test: ## Teste rápido (apenas primeira rodada)
	@echo "⚡ Teste rápido..."
	@go run test/test_csv.go assets/intents_pre_loaded.csv | tail -n 20

clean: ## Limpa arquivos temporários
	@echo "🧹 Limpando..."
	@rm -f test/*.log test/report.json test/synthetic_variations.csv
	@rm -rf bin/
	@echo "✅ Limpo!"

deps: ## Instala dependências
	@echo "📦 Instalando dependências..."
	@go mod download
	@go mod tidy
	@echo "✅ Dependências instaladas"

docker-build: ## Constrói imagem Docker
	@echo "🐳 Construindo imagem Docker..."
	@docker build -t ura-intent:latest .

docker-run: ## Roda via Docker
	@echo "🐳 Rodando via Docker..."
	@docker run -p $(API_PORT):$(API_PORT) -e OPENROUTER_API_KEY=$(OPENROUTER_API_KEY) -e PORT=$(API_PORT) ura-intent:latest

check-api: ## Verifica se a API está online
	@echo "🔍 Verificando API..."
	@curl -s http://localhost:$(API_PORT)/api/healthz | grep -q "ok" && echo "✅ API online!" || echo "❌ API offline"

dev: ## Modo desenvolvimento (inicia servidor em background e roda testes)
	@echo "🔧 Modo desenvolvimento..."
	@make run & sleep 2 && make test

all: deps build test ## Instala deps, compila e testa
