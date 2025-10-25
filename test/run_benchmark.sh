#!/bin/bash
# Script de benchmark completo para o hackathon
# Simula as duas rodadas de testes: 93 intenções base + 80 variações

set -e

echo "🏆 HACKATHON BENCHMARK - Credsystem & Golang SP"
echo "================================================"
echo ""

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações
API_URL="${API_URL:-http://localhost:8080}"
OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"

if [ -z "$OPENROUTER_API_KEY" ]; then
    echo -e "${RED}❌ Erro: OPENROUTER_API_KEY não configurada${NC}"
    echo "Configure com: export OPENROUTER_API_KEY=seu_token"
    exit 1
fi

# Verificar se a API está rodando
echo "🔍 Verificando API..."
if ! curl -s "$API_URL/api/healthz" > /dev/null 2>&1; then
    echo -e "${RED}❌ API não está respondendo em $API_URL${NC}"
    echo "Inicie o servidor com: go run main.go"
    exit 1
fi
echo -e "${GREEN}✅ API online em $API_URL${NC}"
echo ""

# Gerar variações sintéticas
echo "🔄 Gerando variações sintéticas para simular testes secretos..."
python3 test/generate_variations.py assets/intents_pre_loaded.csv test/synthetic_variations.csv 5
echo ""

# Rodada 1: Teste com 93 intenções base
echo "================================================"
echo "📋 RODADA 1: Testando 93 intenções base"
echo "================================================"
echo ""
go run test/test_csv.go assets/intents_pre_loaded.csv > test/round1.log 2>&1
ROUND1_EXIT=$?

if [ $ROUND1_EXIT -eq 0 ]; then
    echo -e "${GREEN}✅ Rodada 1 concluída com sucesso${NC}"
else
    echo -e "${YELLOW}⚠️  Rodada 1 teve falhas (veja test/round1.log)${NC}"
fi
tail -n 15 test/round1.log
echo ""

# Rodada 2: Teste com variações sintéticas (simula 80 testes secretos)
echo "================================================"
echo "📋 RODADA 2: Testando variações sintéticas"
echo "================================================"
echo ""
go run test/test_csv.go test/synthetic_variations.csv > test/round2.log 2>&1
ROUND2_EXIT=$?

if [ $ROUND2_EXIT -eq 0 ]; then
    echo -e "${GREEN}✅ Rodada 2 concluída com sucesso${NC}"
else
    echo -e "${YELLOW}⚠️  Rodada 2 teve falhas (veja test/round2.log)${NC}"
fi
tail -n 15 test/round2.log
echo ""

# Análise final combinada
echo "================================================"
echo "📊 ANÁLISE FINAL COMBINADA"
echo "================================================"
echo ""

# Extrair métricas dos logs
ROUND1_SUCCESS=$(grep -oP '✅ Sucessos: \K\d+' test/round1.log || echo "0")
ROUND1_FAILURES=$(grep -oP '❌ Falhas: \K\d+' test/round1.log || echo "0")
ROUND1_TIME=$(grep -oP '⏱️  Tempo médio: \K\d+' test/round1.log || echo "0")

ROUND2_SUCCESS=$(grep -oP '✅ Sucessos: \K\d+' test/round2.log || echo "0")
ROUND2_FAILURES=$(grep -oP '❌ Falhas: \K\d+' test/round2.log || echo "0")
ROUND2_TIME=$(grep -oP '⏱️  Tempo médio: \K\d+' test/round2.log || echo "0")

# Calcular totais
TOTAL_SUCCESS=$((ROUND1_SUCCESS + ROUND2_SUCCESS))
TOTAL_FAILURES=$((ROUND1_FAILURES + ROUND2_FAILURES))
TOTAL_TESTS=$((TOTAL_SUCCESS + TOTAL_FAILURES))
AVG_TIME=$(( (ROUND1_TIME + ROUND2_TIME) / 2 ))

# Calcular score
SCORE_SUCCESS=$(echo "$TOTAL_SUCCESS * 10" | bc)
SCORE_FAILURES=$(echo "$TOTAL_FAILURES * 50" | bc)
SCORE_TIME=$(echo "$AVG_TIME * 0.01" | bc)
FINAL_SCORE=$(echo "$SCORE_SUCCESS - $SCORE_FAILURES - $SCORE_TIME" | bc)

echo "Rodada 1 (93 testes base):"
echo "  ✅ Sucessos: $ROUND1_SUCCESS"
echo "  ❌ Falhas: $ROUND1_FAILURES"
echo "  ⏱️  Tempo médio: ${ROUND1_TIME}ms"
echo ""
echo "Rodada 2 (variações sintéticas):"
echo "  ✅ Sucessos: $ROUND2_SUCCESS"
echo "  ❌ Falhas: $ROUND2_FAILURES"
echo "  ⏱️  Tempo médio: ${ROUND2_TIME}ms"
echo ""
echo "================================================"
echo "RESULTADO FINAL:"
echo "================================================"
echo "Total de testes: $TOTAL_TESTS"
echo "✅ Sucessos totais: $TOTAL_SUCCESS"
echo "❌ Falhas totais: $TOTAL_FAILURES"
echo "📈 Taxa de acerto: $(echo "scale=2; $TOTAL_SUCCESS * 100 / $TOTAL_TESTS" | bc)%"
echo "⏱️  Tempo médio: ${AVG_TIME}ms"
echo ""
echo "================================================"
echo "🏆 SCORE FINAL DO HACKATHON"
echo "================================================"
echo "Sucessos: +${SCORE_SUCCESS} pts ($TOTAL_SUCCESS × 10)"
echo "Falhas: -${SCORE_FAILURES} pts ($TOTAL_FAILURES × 50)"
echo "Tempo: -${SCORE_TIME} pts ($AVG_TIME × 0.01)"
echo ""
if (( $(echo "$FINAL_SCORE > 0" | bc -l) )); then
    echo -e "${GREEN}🎉 SCORE TOTAL: ${FINAL_SCORE} pontos${NC}"
else
    echo -e "${RED}😔 SCORE TOTAL: ${FINAL_SCORE} pontos${NC}"
fi
echo ""

# Recomendações
echo "================================================"
echo "💡 RECOMENDAÇÕES"
echo "================================================"

if [ "$TOTAL_FAILURES" -gt 5 ]; then
    echo "⚠️  Taxa de falhas alta! Considere:"
    echo "   - Revisar prompt em main.go"
    echo "   - Adicionar mais exemplos de variações"
    echo "   - Testar outro modelo de IA"
fi

if [ "$AVG_TIME" -gt 1000 ]; then
    echo "⚠️  Tempo de resposta alto! Considere:"
    echo "   - Usar modelo mais rápido"
    echo "   - Otimizar prompt (menor = mais rápido)"
    echo "   - Implementar cache de respostas"
fi

if [ "$AVG_TIME" -lt 500 ] && [ "$TOTAL_FAILURES" -lt 5 ]; then
    echo -e "${GREEN}🎯 Excelente performance! Continue assim!${NC}"
fi

echo ""
echo "📄 Logs detalhados salvos em:"
echo "   - test/round1.log"
echo "   - test/round2.log"
echo "   - test/report.json"
echo ""

# Exit code baseado no score
if (( $(echo "$FINAL_SCORE > 1000" | bc -l) )); then
    exit 0
else
    exit 1
fi
