#!/usr/bin/env python3
"""
Gerador EXTENSIVO de variações para validação robusta do prompt.
Cria 120+ variações com erros, sotaques regionais e coloquialismos extremos.
"""

import csv
import random
import re

# Variações regionais brasileiras
REGIONAL_VARIATIONS = {
    'nordeste': [
        ('está', 'tá'), ('você', 'tu'), ('cartão', 'cartãozin'),
        ('preciso', 'to precisando'), ('quero', 'queria'),
        ('meu', 'mermo'), ('não', 'num'), ('senha', 'sinhazinha')
    ],
    'sul': [
        ('cartão', 'cartãozão'), ('preciso', 'to precisando'),
        ('não', 'não'), ('vocês', 'vocês'), ('falar', 'falar'),
        ('tchê', ' tchê'), ('bah', ' bah')
    ],
    'norte': [
        ('está', 'ta'), ('você', 'ocê'), ('cartão', 'cartãozin'),
        ('preciso', 'preciso'), ('maninho', ' maninho')
    ],
}

# Erros de digitação comuns
TYPOS = [
    ('cartão', 'cartao'), ('cartão', 'cartaum'), ('cartão', 'catão'),
    ('senha', 'cemha'), ('senha', 'cenha'), ('limite', 'limiti'),
    ('fatura', 'faturra'), ('boleto', 'boleto'), ('seguro', 'ceguro'),
    ('negociação', 'negociaçao'), ('acordo', 'acôrdo'),
    ('disponível', 'disponivel'), ('código', 'codigo'),
]

# Gírias e expressões informais extremas
INFORMAL = [
    'aí', 'né', 'mano', 'véi', 'irmão', 'cara', 'pow', 'rapaz',
    'moço', 'ó', 'ei', 'psiu', 'fala', 'e aí'
]

# Base de variações por serviço (16 serviços)
SERVICE_TEMPLATES = {
    1: [  # Consulta Limite
        "quanto eu tenho pra usar",
        "limete disponivel",
        "qto tem d limite",
        "num sei qto tenho",
        "meu limite ta quanto",
        "qero sabe meu limite tchê",
        "qndo fecha a fatura mermo",
        "dia d vencimento",
    ],
    2: [  # Segunda via boleto acordo
        "precizu do boleto do acordo",
        "boleto da negociaçao",
        "reimprimir boleto acôrdo",
        "num tenho o boleto do acordo",
        "cade boleto pra pagar acordo",
        "segunda via boletu acordo",
        "codigo de barras acordo maninho",
        "queria o boleto do acordo",
    ],
    3: [  # Segunda via fatura
        "manda a fatura ai",
        "num recebi minha faturra",
        "segunda via da fatura rapaz",
        "boleto pra pagar cartao",
        "preciso da fatura do mes",
        "reimprimir faturazinha",
        "codigo barras fatura",
        "qero minha fatura né",
    ],
    4: [  # Status Entrega
        "cade meu cartãozin",
        "o cartao num chegô ainda",
        "qndo chega meu cartao",
        "onde ta o cartao q pedi",
        "rastreia cartao pra mim",
        "cartão ta demorando demais véi",
        "num chegou meu cartao ainda",
        "previsao d entrega do cartao",
    ],
    5: [  # Status cartão
        "meu cartao num ta passando",
        "cartao ta recusado",
        "num consegui passa o cartao",
        "cartão num funciona",
        "problema com meu cartão aí",
        "cartao ta bloqueado ou q",
        "por q o cartao num passa",
        "cartãozin num ta funcionando",
    ],
    6: [  # Aumento limite
        "qero mais limiti",
        "aumenta meu limite ai",
        "preciso d mais limite urgente",
        "meu limete ta baixo demais",
        "como faz pra ter mais limite",
        "solicitar aumento d limite tchê",
        "limete muito pequeno",
        "qeria um limite maior",
    ],
    7: [  # Cancelamento
        "vo cancela esse cartao",
        "qero encerra o cartão",
        "num qero mais esse cartao",
        "como cancelu",
        "desiste do cartão pow",
        "bloqueia cartão definitivo",
        "cancelamento d cartao",
        "queria cancela o cartãozin",
    ],
    8: [  # Seguradoras
        "telefoni da seguradora",
        "qero cancela o ceguro",
        "numero do seguro do cartão",
        "como fala com seguradora",
        "contato da seguradora ai",
        "assistencia do cartão",
        "cancela assistência",
        "preciso do tel do seguro",
    ],
    9: [  # Desbloqueio
        "desbloqueia cartao pra mim",
        "qero ativa o cartão novo",
        "como faiz pra desbloquea",
        "cartão pra uso imediatu",
        "desbloqueio pra compras",
        "libera meu cartao ai",
        "ativar cartãozin novo",
        "preciso desbloquear urgente",
    ],
    10: [  # Senha
        "esqueci minha cemha",
        "num lembro a senha do cartão",
        "trocar sinhazinha",
        "precisu d nova senha",
        "recupera senha pra mim",
        "cenha bloqueada",
        "como mudo a senha",
        "resetar senha do cartao",
    ],
    11: [  # Perda/roubo
        "perdi meu cartãozin",
        "roubaram o cartao",
        "cartão furtado véi",
        "extravio d cartão",
        "bloqueia cartao por roubo",
        "num acho mais o cartão",
        "me roubaram e levaram cartao",
        "perda do cartão urgente",
    ],
    12: [  # Consulta Saldo
        "quanto tem na minha conta",
        "qero consulta saldo",
        "qual meu saldo atual",
        "saldo disponivel na conta",
        "extrato da conta correnti",
        "tem quanto na conta",
        "saldo conta corrente",
        "ver saldo da conta",
    ],
    13: [  # Pagamento contas
        "qero pagar minha fatura",
        "pagar boleto aqui",
        "vou fazer um pagamento",
        "efetua pagamento pra mim",
        "queria pagar a fatura",
        "pagamento d conta",
        "pagar fatura do cartão",
        "fazer pagamento urgente",
    ],
    14: [  # Reclamações
        "qero faze uma queixa",
        "abrir reclamaçao",
        "registra esse problema ai",
        "protocolo d reclamação",
        "reclama do atendimento",
        "num to satisfeito",
        "queria faze uma reclamação",
        "fazer queixa urgente",
    ],
    15: [  # Atendimento humano
        "qero fala com gente",
        "transfere pra atendenti",
        "preciso d um humano ai",
        "falar com pessoa",
        "atendente humano por favor",
        "me passa pra alguem",
        "queria fala com atendente",
        "atendimento pessoal urgente",
    ],
    16: [  # Token proposta
        "codigo pra fazer cartão",
        "token da proposta ai",
        "recebe codigo do cartao",
        "numero d token",
        "proposta tokem",
        "codigo d token da proposta",
        "token pra faze meu cartao",
        "queria o token da proposta",
    ],
}


def apply_random_variations(text):
    """Aplica variações aleatórias para simular fala natural."""
    result = text.lower()

    # Regional (30% chance)
    if random.random() < 0.3:
        region = random.choice(list(REGIONAL_VARIATIONS.keys()))
        for original, variation in REGIONAL_VARIATIONS[region]:
            if original in result:
                result = result.replace(original, variation, 1)
                break

    # Typos (20% chance)
    if random.random() < 0.2:
        for original, typo in random.sample(TYPOS, min(3, len(TYPOS))):
            if original in result:
                result = result.replace(original, typo, 1)
                break

    # Informal (40% chance)
    if random.random() < 0.4:
        word = random.choice(INFORMAL)
        if random.random() > 0.5:
            result = f"{word}, {result}"
        else:
            result = f"{result} {word}"

    # Remove pontuação (30% chance)
    if random.random() < 0.3:
        result = result.replace('?', '').replace('!', '').replace(',', '')

    return result


def generate_extended_test_set(output_file='test/extended_variations.csv', num_variations=8):
    """Gera conjunto estendido de testes com 120+ variações."""

    all_tests = []

    # Mapeamento de IDs para nomes de serviços
    service_names = {
        1: "Consulta Limite / Vencimento do cartão / Melhor dia de compra",
        2: "Segunda via de boleto de acordo",
        3: "Segunda via de Fatura",
        4: "Status de Entrega do Cartão",
        5: "Status de cartão",
        6: "Solicitação de aumento de limite",
        7: "Cancelamento de cartão",
        8: "Telefones de seguradoras",
        9: "Desbloqueio de Cartão",
        10: "Esqueceu senha / Troca de senha",
        11: "Perda e roubo",
        12: "Consulta do Saldo",
        13: "Pagamento de contas",
        14: "Reclamações",
        15: "Atendimento humano",
        16: "Token de proposta",
    }

    # Gerar variações para cada serviço
    for service_id, templates in SERVICE_TEMPLATES.items():
        service_name = service_names[service_id]

        # Usar templates + aplicar variações
        for template in templates:
            # Template original
            all_tests.append({
                'service_id': service_id,
                'service_name': service_name,
                'intent': template
            })

            # Gerar variação adicional
            if len(all_tests) < 120:
                variation = apply_random_variations(template)
                if variation != template:  # Só adiciona se for diferente
                    all_tests.append({
                        'service_id': service_id,
                        'service_name': service_name,
                        'intent': variation
                    })

    # Embaralhar
    random.shuffle(all_tests)

    # Limitar a 120
    all_tests = all_tests[:120]

    # Salvar CSV com separador ;
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['service_id', 'service_name', 'intent'], delimiter=';')
        writer.writeheader()
        writer.writerows(all_tests)

    print(f"✅ Gerado {len(all_tests)} testes extensivos em {output_file}")
    print(f"📊 ~{len(all_tests)//16} variações por serviço")

    # Estatísticas
    services_count = {}
    for test in all_tests:
        sid = test['service_id']
        services_count[sid] = services_count.get(sid, 0) + 1

    print(f"\n📈 Distribuição:")
    for sid in sorted(services_count.keys()):
        print(f"   Serviço {sid}: {services_count[sid]} testes")


if __name__ == '__main__':
    print("🔧 Gerando 120 testes extensivos com variações brasileiras extremas...\n")
    generate_extended_test_set()
    print("\n💡 Execute: go run test/test_csv_semicolon.go test/extended_variations.csv")
