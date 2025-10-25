#!/bin/bash

# Script para validar outputs da API com exemplos variados

API_URL="http://localhost:8080/api/find-service"

echo "═══════════════════════════════════════════════════════════════"
echo "        VALIDAÇÃO DE OUTPUTS DA API - INTENT CLASSIFIER"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Função para testar e exibir resultado formatado
test_intent() {
    local intent="$1"
    local description="$2"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 $description"
    echo "   Intent: \"$intent\""
    echo ""

    response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{\"intent\":\"$intent\"}")

    # Formatar JSON para melhor visualização
    echo "📤 Resposta da API:"
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo ""
}

# ============================================================
# CASOS VÁLIDOS - Deve retornar success: true
# ============================================================

echo "🟢 CASOS VÁLIDOS (deve retornar success: true)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

test_intent "quero aumentar meu limite" "Caso 1: Aumento de limite"
test_intent "quando vence minha fatura" "Caso 2: Vencimento da fatura"
test_intent "preciso da segunda via do boleto de acordo" "Caso 3: Boleto de acordo"
test_intent "quero consultar meu saldo" "Caso 4: Consulta de saldo"
test_intent "perdi meu cartão" "Caso 5: Perda de cartão"
test_intent "esqueci minha senha" "Caso 6: Esqueceu senha"
test_intent "quero falar com atendente" "Caso 7: Atendimento humano"
test_intent "cartao num chegou ainda vei" "Caso 8: Gíria - Status de entrega"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ============================================================
# CASOS INVÁLIDOS - Deve retornar success: false
# ============================================================

echo "🔴 CASOS INVÁLIDOS (deve retornar success: false)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

test_intent "quero pedir uma pizza" "Caso 1: Pizza (não é serviço bancário)"
test_intent "qual o horário do cinema" "Caso 2: Cinema (não é serviço bancário)"
test_intent "quero comprar um notebook" "Caso 3: Notebook (não é serviço bancário)"
test_intent "previsão do tempo" "Caso 4: Clima (não é serviço bancário)"

echo "═══════════════════════════════════════════════════════════════"
echo "                    VALIDAÇÃO CONCLUÍDA"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Casos válidos devem ter: \"success\": true"
echo "❌ Casos inválidos devem ter: \"success\": false, \"error\": \"Serviço não encontrado\""
echo ""
