#!/bin/bash

# Testa 10 intenções que NÃO existem no catálogo de serviços
# Espera-se: {"success":false,"error":"Serviço não encontrado"}

API_URL="http://localhost:8080/api/find-service"

echo "🧪 Testando 10 intenções INVÁLIDAS (espera-se erro 'Serviço não encontrado')"
echo "================================================================"

# Array de intenções inválidas
intents=(
  "quero pedir uma pizza de calabresa"
  "qual o horário do cinema hoje"
  "previsão do tempo para amanhã"
  "quanto custa um carro zero km"
  "quero agendar consulta médica"
  "como faço para votar nas eleições"
  "qual o placar do jogo de hoje"
  "quero comprar um notebook gamer"
  "como faço para tirar passaporte"
  "onde fica a farmácia mais próxima"
)

success_count=0
fail_count=0

for i in "${!intents[@]}"; do
  intent="${intents[$i]}"
  num=$((i + 1))

  echo ""
  echo "[$num/10] Testando: \"$intent\""

  response=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{\"intent\":\"$intent\"}")

  echo "Resposta: $response"

  # Verifica se contém "success":false e "Serviço não encontrado"
  if echo "$response" | grep -q '"success":false' && echo "$response" | grep -q "Serviço não encontrado"; then
    echo "✅ PASSOU - Retornou erro corretamente"
    ((success_count++))
  else
    echo "❌ FALHOU - Deveria retornar erro 'Serviço não encontrado'"
    ((fail_count++))
  fi
done

echo ""
echo "================================================================"
echo "RESULTADO FINAL:"
echo "✅ Sucessos: $success_count/10"
echo "❌ Falhas: $fail_count/10"

if [ $fail_count -eq 0 ]; then
  echo "🎉 TODOS OS TESTES PASSARAM!"
  exit 0
else
  echo "⚠️  Alguns testes falharam"
  exit 1
fi
