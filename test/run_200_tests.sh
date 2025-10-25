#!/bin/bash

# Script de teste completo com 200 casos de teste
# Inclui: 93 obrigatórios + 10 contextuais + 97 aleatórios realistas

API_URL="${API_URL:-http://localhost:8080}"
TOTAL=0
SUCCESS=0
FAIL=0
TOTAL_TIME=0

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para testar uma intenção
test_intent() {
    local expected_id=$1
    local intent=$2
    local test_num=$3

    TOTAL=$((TOTAL + 1))

    # Fazer request e medir tempo
    local start=$(date +%s%3N)
    local response=$(curl -s -X POST "$API_URL/api/find-service" \
        -H "Content-Type: application/json" \
        -d "{\"intent\":\"$intent\"}")
    local end=$(date +%s%3N)
    local elapsed=$((end - start))
    TOTAL_TIME=$((TOTAL_TIME + elapsed))

    # Parse response
    local actual_id=$(echo "$response" | grep -o '"service_id":[0-9]*' | grep -o '[0-9]*')

    if [ "$actual_id" = "$expected_id" ]; then
        SUCCESS=$((SUCCESS + 1))
        echo -e "${GREEN}✅ [$test_num/$TOTAL] ${elapsed}ms${NC} - $intent"
    else
        FAIL=$((FAIL + 1))
        echo -e "${RED}❌ [$test_num/$TOTAL] ${elapsed}ms${NC} - $intent"
        echo -e "   Esperado: ID $expected_id | Recebido: ID ${actual_id:-NULL}"
    fi
}

echo "🧪 Iniciando bateria de 200 testes..."
echo "📍 API: $API_URL"
echo ""

# ========================================
# PARTE 1: 93 TESTES OBRIGATÓRIOS
# ========================================
echo "📋 PARTE 1: 93 Testes Obrigatórios do CSV"
echo "=========================================="

# ID 1 - Consulta Limite/Vencimento (6 testes)
test_intent 1 "Quanto tem disponível para usar" 1
test_intent 1 "quando fecha minha fatura" 2
test_intent 1 "Quando vence meu cartão" 3
test_intent 1 "quando posso comprar" 4
test_intent 1 "vencimento da fatura" 5
test_intent 1 "valor para gastar" 6

# ID 2 - Segunda via boleto acordo (6 testes)
test_intent 2 "segunda via boleto de acordo" 7
test_intent 2 "Boleto para pagar minha negociação" 8
test_intent 2 "código de barras acordo" 9
test_intent 2 "preciso pagar negociação" 10
test_intent 2 "enviar boleto acordo" 11
test_intent 2 "boleto da negociação" 12

# ID 3 - Segunda via de Fatura (6 testes)
test_intent 3 "quero meu boleto" 13
test_intent 3 "segunda via de fatura" 14
test_intent 3 "código de barras fatura" 15
test_intent 3 "quero a fatura do cartão" 16
test_intent 3 "enviar boleto da fatura" 17
test_intent 3 "fatura para pagamento" 18

# ID 4 - Status de Entrega (6 testes)
test_intent 4 "onde está meu cartão" 19
test_intent 4 "meu cartão não chegou" 20
test_intent 4 "status da entrega do cartão" 21
test_intent 4 "cartão em transporte" 22
test_intent 4 "previsão de entrega do cartão" 23
test_intent 4 "cartão foi enviado?" 24

# ID 5 - Status de cartão (6 testes)
test_intent 5 "não consigo passar meu cartão" 25
test_intent 5 "meu cartão não funciona" 26
test_intent 5 "cartão recusado" 27
test_intent 5 "cartão não está passando" 28
test_intent 5 "status do cartão ativo" 29
test_intent 5 "problema com cartão" 30

# ID 6 - Aumento de limite (6 testes)
test_intent 6 "quero mais limite" 31
test_intent 6 "aumentar limite do cartão" 32
test_intent 6 "solicitar aumento de crédito" 33
test_intent 6 "preciso de mais limite" 34
test_intent 6 "pedido de aumento de limite" 35
test_intent 6 "limite maior no cartão" 36

# ID 7 - Cancelamento (5 testes - note que linha 43 está sem cartão no final)
test_intent 7 "cancelar cartão" 37
test_intent 7 "quero encerrar meu cartão" 38
test_intent 7 "bloquear cartão definitivamente" 39
test_intent 7 "cancelamento de crédito" 40
test_intent 7 "desistir do cartão" 41

# ID 8 - Seguro (6 testes)
test_intent 8 "quero cancelar seguro" 42
test_intent 8 "telefone do seguro" 43
test_intent 8 "contato da seguradora" 44
test_intent 8 "preciso falar com o seguro" 45
test_intent 8 "seguro do cartão" 46
test_intent 8 "cancelar assistência" 47

# ID 9 - Desbloqueio (6 testes)
test_intent 9 "desbloquear cartão" 48
test_intent 9 "ativar cartão novo" 49
test_intent 9 "como desbloquear meu cartão" 50
test_intent 9 "quero desbloquear o cartão" 51
test_intent 9 "cartão para uso imediato" 52
test_intent 9 "desbloqueio para compras" 53

# ID 10 - Senha (6 testes)
test_intent 10 "não tenho mais a senha do cartão" 54
test_intent 10 "esqueci minha senha" 55
test_intent 10 "trocar senha do cartão" 56
test_intent 10 "preciso de nova senha" 57
test_intent 10 "recuperar senha" 58
test_intent 10 "senha bloqueada" 59

# ID 11 - Perda e roubo (6 testes)
test_intent 11 "perdi meu cartão" 60
test_intent 11 "roubaram meu cartão" 61
test_intent 11 "cartão furtado" 62
test_intent 11 "perda do cartão" 63
test_intent 11 "bloquear cartão por roubo" 64
test_intent 11 "extravio de cartão" 65

# ID 12 - Consulta Saldo (6 testes)
test_intent 12 "saldo conta corrente" 66
test_intent 12 "consultar saldo" 67
test_intent 12 "quanto tenho na conta" 68
test_intent 12 "extrato da conta" 69
test_intent 12 "saldo disponível" 70
test_intent 12 "meu saldo atual" 71

# ID 13 - Pagamento (5 testes)
test_intent 13 "quero pagar minha conta" 72
test_intent 13 "pagar boleto" 73
test_intent 13 "pagamento de conta" 74
test_intent 13 "quero pagar fatura" 75
test_intent 13 "efetuar pagamento" 76

# ID 14 - Reclamações (6 testes)
test_intent 14 "quero reclamar" 77
test_intent 14 "abrir reclamação" 78
test_intent 14 "fazer queixa" 79
test_intent 14 "reclamar atendimento" 80
test_intent 14 "registrar problema" 81
test_intent 14 "protocolo de reclamação" 82

# ID 15 - Atendimento humano (5 testes)
test_intent 15 "falar com uma pessoa" 83
test_intent 15 "preciso de humano" 84
test_intent 15 "transferir para atendente" 85
test_intent 15 "quero falar com atendente" 86
test_intent 15 "atendimento pessoal" 87

# ID 16 - Token (6 testes)
test_intent 16 "código para fazer meu cartão" 88
test_intent 16 "token de proposta" 89
test_intent 16 "receber código do cartão" 90
test_intent 16 "proposta token" 91
test_intent 16 "número de token" 92
test_intent 16 "código de token da proposta" 93

echo ""
echo "=========================================="
echo "✅ Parte 1 completa: 93 testes obrigatórios"
echo ""

# ========================================
# PARTE 2: 10 TESTES CONTEXTUAIS COMPLEXOS
# ========================================
echo "📋 PARTE 2: 10 Testes Contextuais Complexos"
echo "=========================================="

test_intent 1 "Oi meu amor, to aqui no mercado fazendo compra pra semana ne, ai fui passar o cartao na maquininha e a moça falou que ta sem limite, mas eu lembro que mes passado eu tinha uns 2 mil ainda, sera que da pra voce me falar quanto que eu tenho disponivel pra usar ainda? Preciso saber se da pra terminar as compra ou se vou ter que deixar alguma coisa." 94

test_intent 3 "Bom dia, olha eu to com um probleminha aqui, perdi o boleto da fatura do mes passado, joguei fora sem querer junto com os papel da farmacia, ai agora to precisando pagar mas num tenho o codigo de barras, como que eu faço pra pegar a segunda via? Minha fatura vence semana que vem e eu num quero atrasar ne." 95

test_intent 4 "E ai pessoal, faz uns 15 dias que eu fiz o pedido do meu cartao novo la no aplicativo, voceis falaram que ia chegar em 10 dias uteis, so que ate agora nada, ja olhei na caixa de correio todo dia, sera que perderam meu cartao no caminho? Queria saber se tem como rastrear onde que ele ta." 96

test_intent 10 "Opa, to com um pepino aqui viu, tentei fazer uma compra ontem no shopping e pediram a senha, so que eu num lembro qual que é a senha, faz tempo que eu num uso, sempre passo por aproximação ne, ai agora to precisando usar e num sei a senha, como que faz pra recuperar ou cadastrar uma nova?" 97

test_intent 12 "Fala meu querido, to aqui fazendo umas contas pra pagar no final do mes, preciso saber quanto que eu tenho na conta corrente pra ver se vai dar pra pagar tudo, da pra voce consultar pra mim quanto que ta o meu saldo disponivel? É urgente viu, preciso decidir se vou ter que pegar um dinheiro emprestado ou não." 98

test_intent 13 "Bom dia moça, olha so, eu recebi aqui o boleto da minha fatura do cartao que vence amanha, ai eu queria pagar hoje mesmo pra nao correr risco de atrasar ne, mas to em duvida se eu pago pelo aplicativo do banco ou se eu vou ate uma lotérica, qual que voce acha melhor? Quero efetuar o pagamento o mais rapido possivel." 99

test_intent 14 "Olha, eu to muito insatisfeita viu, liguei ontem pra central de voceis umas 3 vezes, fiquei mais de 40 minutos esperando na linha em cada ligação e ninguem me atendeu direito, desligaram na minha cara duas vezes, isso é uma falta de respeito tremenda com o cliente, quero registrar uma reclamação formal sobre esse atendimento pessimo que eu recebi." 100

test_intent 15 "Moço, desculpa incomodar mas é o seguinte, eu sou meio ruim com essas tecnologia, num consigo resolver as coisa sozinho no aplicativo não, sera que da pra voce me transferir pra falar com uma pessoa de verdade? Preciso de um atendente humano que possa me ajudar com calma porque eu num to conseguindo entender essas opção automatica." 101

test_intent 16 "Oi querida, seguinte, semana passada eu fiz a proposta pro cartao novo la na loja, a vendedora falou que ia chegar um codigo no meu celular pra eu finalizar o cadastro, so que até agora num chegou nada, sera que tem como voces me enviarem esse token de proposta de novo? Preciso desse codigo pra conseguir liberar meu cartao." 102

test_intent 11 "Gente, to desesperado aqui, fui assaltado ontem a noite quando tava voltando do trabalho, levaram minha carteira com tudo dentro, documentos, dinheiro e meu cartao de credito, preciso bloquear urgente esse cartao antes que os ladrao façam compra, por favor me ajuda a bloquear por causa do roubo, to com medo de fazer compra indevida." 103

echo ""
echo "=========================================="
echo "✅ Parte 2 completa: 10 testes contextuais"
echo ""

# ========================================
# PARTE 3: 97 TESTES ALEATÓRIOS REALISTAS
# ========================================
echo "📋 PARTE 3: 97 Testes Aleatórios Realistas"
echo "=========================================="

# Limite/Vencimento (ID 1) - 8 testes
test_intent 1 "quanto eu posso gastar ainda no cartao?" 104
test_intent 1 "vc pode me dizer quando fecha a fatura?" 105
test_intent 1 "qual dia que vence o boleto do cartao" 106
test_intent 1 "tenho limite disponivel?" 107
test_intent 1 "qual o melhor dia pra eu fazer compra?" 108
test_intent 1 "quanto tem liberado pra mim usar" 109
test_intent 1 "minha fatura fecha dia quanto?" 110
test_intent 1 "limite atual do cartao" 111

# Boleto Acordo (ID 2) - 6 testes
test_intent 2 "queria o boleto da minha negociação" 112
test_intent 2 "perdi o codigo do acordo" 113
test_intent 2 "me manda o boleto do parcelamento" 114
test_intent 2 "preciso segunda via do acordo" 115
test_intent 2 "como pago o acordo que fiz" 116
test_intent 2 "boleto da renegociação" 117

# Fatura (ID 3) - 8 testes
test_intent 3 "cade o boleto do mes" 118
test_intent 3 "não recebi a fatura" 119
test_intent 3 "me envia o codigo da fatura" 120
test_intent 3 "joguei fora o boleto" 121
test_intent 3 "preciso imprimir a fatura" 122
test_intent 3 "quero obter minha fatura" 123
test_intent 3 "segunda via do boleto do cartao" 124
test_intent 3 "fatura em atraso" 125

# Entrega Cartão (ID 4) - 6 testes
test_intent 4 "cade meu cartao que nao chega" 126
test_intent 4 "quanto tempo demora pra chegar" 127
test_intent 4 "ja foi enviado meu cartao?" 128
test_intent 4 "rastreio do cartao" 129
test_intent 4 "solicitei ha 2 semanas" 130
test_intent 4 "cartao nao foi entregue" 131

# Status Cartão (ID 5) - 6 testes
test_intent 5 "meu cartao ta dando erro" 132
test_intent 5 "nao aceita em loja nenhuma" 133
test_intent 5 "todas as compras estao sendo negadas" 134
test_intent 5 "cartao ta inativo?" 135
test_intent 5 "porque nao consigo usar" 136
test_intent 5 "cartao com defeito" 137

# Aumento Limite (ID 6) - 6 testes
test_intent 6 "queria aumentar meu limite" 138
test_intent 6 "da pra ter mais credito" 139
test_intent 6 "preciso de limite maior" 140
test_intent 6 "solicitar mais limite" 141
test_intent 6 "como faço pra aumentar" 142
test_intent 6 "quero mais crédito no cartao" 143

# Cancelamento (ID 7) - 8 testes
test_intent 7 "quero cancelar meu cartão" 144
test_intent 7 "vou encerrar a conta" 145
test_intent 7 "não quero mais o cartao" 146
test_intent 7 "bloquear o cartão" 147
test_intent 7 "to desconfiado de golpe quero bloquear" 148
test_intent 7 "cancelar por suspeita de fraude" 149
test_intent 7 "bloquear preventivamente" 150
test_intent 7 "desistir do credito" 151

# Seguro (ID 8) - 5 testes
test_intent 8 "quero falar com a seguradora" 152
test_intent 8 "numero da assistencia" 153
test_intent 8 "cancelar o seguro do cartao" 154
test_intent 8 "telefone pra acionar seguro" 155
test_intent 8 "como cancelo essa assistencia" 156

# Desbloqueio (ID 9) - 5 testes
test_intent 9 "como ativo meu cartao" 157
test_intent 9 "preciso desbloquear" 158
test_intent 9 "liberar cartao pra uso" 159
test_intent 9 "ativação do cartao" 160
test_intent 9 "habilitar cartão novo" 161

# Senha (ID 10) - 6 testes
test_intent 10 "nao lembro a senha" 162
test_intent 10 "quero trocar minha senha" 163
test_intent 10 "como recupero a senha" 164
test_intent 10 "resetar senha do cartao" 165
test_intent 10 "cadastrar senha nova" 166
test_intent 10 "minha senha ta bloqueada" 167

# Perda/Roubo (ID 11) - 6 testes
test_intent 11 "perdi minha carteira com o cartao" 168
test_intent 11 "fui roubado e levaram meu cartao" 169
test_intent 11 "cartão extraviado" 170
test_intent 11 "não acho mais meu cartao" 171
test_intent 11 "bloquear por perda" 172
test_intent 11 "furtaram meu cartao na rua" 173

# Saldo (ID 12) - 6 testes
test_intent 12 "quanto tenho de saldo" 174
test_intent 12 "ver saldo da conta" 175
test_intent 12 "consulta de saldo" 176
test_intent 12 "meu saldo ta quanto" 177
test_intent 12 "quanto dinheiro tenho" 178
test_intent 12 "saldo atual da minha conta" 179

# Pagamento (ID 13) - 6 testes
test_intent 13 "vou pagar a fatura" 180
test_intent 13 "quero efetuar um pagamento" 181
test_intent 13 "pagar minha conta" 182
test_intent 13 "fazer pagamento de boleto" 183
test_intent 13 "como pago minha fatura" 184
test_intent 13 "realizar pagamento" 185

# Reclamações (ID 14) - 5 testes
test_intent 14 "to muito insatisfeito" 186
test_intent 14 "quero fazer uma queixa" 187
test_intent 14 "registrar uma reclamacao" 188
test_intent 14 "protocolo de queixa" 189
test_intent 14 "abrir chamado de reclamação" 190

# Atendimento Humano (ID 15) - 5 testes
test_intent 15 "me passa pra uma pessoa" 191
test_intent 15 "atendente humano por favor" 192
test_intent 15 "falar com gente de verdade" 193
test_intent 15 "transferir pra operador" 194
test_intent 15 "preciso de atendimento pessoal" 195

# Token (ID 16) - 3 testes
test_intent 16 "cadê o token que pedi" 196
test_intent 16 "codigo da proposta do cartao" 197
test_intent 16 "enviar token novamente" 198

# Casos INVÁLIDOS (não relacionados ao serviço) - 2 testes
test_intent 0 "qual a previsao do tempo hoje" 199
test_intent 0 "quero pedir uma pizza de calabresa" 200

echo ""
echo "=========================================="
echo "✅ Parte 3 completa: 97 testes aleatórios"
echo ""

# ========================================
# RELATÓRIO FINAL
# ========================================
echo "============================================================"
echo "📊 RELATÓRIO FINAL DOS 200 TESTES"
echo "============================================================"
echo "Total de testes: $TOTAL"
echo -e "✅ Sucessos: ${GREEN}$SUCCESS${NC} ($(awk "BEGIN {printf \"%.1f\", ($SUCCESS/$TOTAL)*100}")%)"
echo -e "❌ Falhas: ${RED}$FAIL${NC} ($(awk "BEGIN {printf \"%.1f\", ($FAIL/$TOTAL)*100}")%)"

if [ $TOTAL -gt 0 ]; then
    AVG_TIME=$(($TOTAL_TIME / $TOTAL))
    echo "⏱️  Tempo médio: ${AVG_TIME}ms"
    echo "⏱️  Tempo total: $(awk "BEGIN {printf \"%.2f\", $TOTAL_TIME/1000}")s"
    echo ""

    # Calcular score
    SCORE=$(awk "BEGIN {printf \"%.2f\", ($SUCCESS * 10.0) - ($FAIL * 50.0) - ($AVG_TIME * 0.01)}")
    echo "🏆 SCORE ESTIMADO: $SCORE pontos"
    echo "   Sucessos: $(awk "BEGIN {printf \"%.0f\", $SUCCESS * 10.0}") pts"
    echo "   Falhas: $(awk "BEGIN {printf \"%.0f\", $FAIL * -50.0}") pts"
    echo "   Tempo: -$(awk "BEGIN {printf \"%.2f\", $AVG_TIME * 0.01}") pts"
fi

echo ""
echo "============================================================"

# Exit com código apropriado
if [ $FAIL -gt 0 ]; then
    exit 1
else
    exit 0
fi
