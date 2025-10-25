#!/usr/bin/env python3
"""
Gerador de variações sintéticas para simular os 80 testes secretos do hackathon.
Cria variações coloquiais, com erros de digitação, gírias e sotaques brasileiros.
"""

import csv
import random
import re
from typing import List, Tuple

# Substituições comuns em português brasileiro coloquial
COLOQUIAL_REPLACEMENTS = [
    (r'\bvou\b', 'vo'),
    (r'\bestou\b', 'to'),
    (r'\bestá\b', 'tá'),
    (r'\bestão\b', 'tão'),
    (r'\bnão\b', 'num'),
    (r'\bpara\b', 'pra'),
    (r'\bcadê\b', 'cade'),
    (r'\bquero\b', 'kero'),
    (r'\bque\b', 'q'),
    (r'\bporque\b', 'pq'),
    (r'\bvocê\b', 'vc'),
    (r'\btambém\b', 'tb'),
    (r'\bmeu\b', 'meo'),
    (r'\bpreciso\b', 'precizu'),
]

# Erros comuns de digitação/pronúncia
TYPO_REPLACEMENTS = [
    ('ão', 'ao'),
    ('ç', 'c'),
    ('á', 'a'),
    ('é', 'e'),
    ('í', 'i'),
    ('ó', 'o'),
    ('ú', 'u'),
    ('ã', 'a'),
]

# Gírias e expressões informais
INFORMAL_ADDITIONS = [
    'aí', 'né', 'pow', 'cara', 'mano', 'ó',
]

# Templates de variações por serviço
SERVICE_VARIATIONS = {
    1: [  # Consulta Limite / Vencimento
        "qual meu limite?",
        "kero sabe meu limite",
        "me fala quanto tenho de limite",
        "limite do cartao por favor",
        "quando vence o cartao?",
    ],
    2: [  # Segunda via boleto acordo
        "kero a 2 via do boleto",
        "cade o boleto do acordo?",
        "precisu do boleto de novo",
        "num recebi o boleto do acordo",
        "reemite o boleto pra mim",
    ],
    3: [  # Segunda via fatura
        "kero a segunda via da fatura",
        "num recebi a fatura esse mes",
        "cade minha fatura?",
        "preciso imprimir a fatura",
        "reemitir fatura",
    ],
    4: [  # Status entrega cartão
        "cade meu cartao q pedi?",
        "quando chega o cartao?",
        "cartao ainda num chegou",
        "quero rastrear meu cartao",
        "onde ta meu cartao?",
    ],
    5: [  # Status de cartão
        "meu cartao ta ativo?",
        "cartao ta funcionando?",
        "qual status do meu cartao",
        "cartao ta bloqueado?",
        "como ta meu cartao?",
    ],
    6: [  # Aumento de limite
        "quero mais limite",
        "meo limite ta muito baixo",
        "preciso aumenta o limite",
        "como faço pra ter mais limite?",
        "limite ta muito pequeno",
    ],
    7: [  # Cancelamento
        "vo cancela esse cartao",
        "kero cancela o cartao",
        "num quero mais o cartao",
        "como cancelo?",
        "quero desistir do cartao",
    ],
    8: [  # Telefones seguradoras
        "numero da seguradora",
        "como falo com a seguradora?",
        "telefone do seguro",
        "preciso aciona o seguro",
        "contato da seguradora",
    ],
    9: [  # Desbloqueio
        "meu cartao ta bloqueado",
        "como desbloqueia o cartao?",
        "kero desbloquear",
        "cartao bloqueado como resolve?",
        "precisu desbloquea",
    ],
    10: [  # Esqueceu senha
        "esqueci a senha",
        "num lembro a senha",
        "como troco a senha?",
        "esqueci minha senha",
        "kero muda a senha",
    ],
    11: [  # Perda e roubo
        "perdi meu cartao",
        "roubaram o cartao",
        "fui assaltado",
        "cartao sumiu",
        "num acho meu cartao",
    ],
    12: [  # Saldo Conta do Mais
        "saldo conta do mais",
        "quanto tenho na conta do mais?",
        "consulta conta do mais",
        "qual meu saldo?",
        "verificar conta do mais",
    ],
    13: [  # Pagamento de contas
        "como pago conta?",
        "kero paga uma conta",
        "pagar boleto",
        "pagamento de conta de luz",
        "fazer um pagamento",
    ],
    14: [  # Reclamações
        "kero reclamar",
        "num to satisfeito",
        "fazer uma reclamacao",
        "quero registra uma queixa",
        "reclamar do atendimento",
    ],
    15: [  # Atendimento humano
        "kero fala com gente",
        "atendente humano",
        "transfere pra alguem",
        "quero falar com pessoa",
        "atendente por favor",
    ],
    16: [  # Token de proposta
        "cade o token?",
        "preciso do token da proposta",
        "token de proposta",
        "me manda o token",
        "codigo da proposta",
    ],
}


def apply_coloquial(text: str) -> str:
    """Aplica transformações coloquiais no texto."""
    result = text.lower()
    for pattern, replacement in COLOQUIAL_REPLACEMENTS:
        result = re.sub(pattern, replacement, result)
    return result


def apply_typos(text: str, probability: float = 0.3) -> str:
    """Adiciona erros de digitação aleatórios."""
    if random.random() > probability:
        return text

    result = text
    for original, typo in random.sample(TYPO_REPLACEMENTS, min(2, len(TYPO_REPLACEMENTS))):
        if original in result:
            result = result.replace(original, typo, 1)
            break
    return result


def add_informal_words(text: str, probability: float = 0.4) -> str:
    """Adiciona palavras informais ao texto."""
    if random.random() > probability:
        return text

    word = random.choice(INFORMAL_ADDITIONS)
    if random.random() > 0.5:
        return f"{text}, {word}"
    else:
        return f"{word}, {text}"


def remove_punctuation(text: str, probability: float = 0.5) -> str:
    """Remove pontuação aleatoriamente."""
    if random.random() > probability:
        return text
    return text.replace('?', '').replace('!', '').replace(',', '')


def generate_variations(intent: str, service_id: int, num_variations: int = 5) -> List[str]:
    """Gera múltiplas variações de uma intenção."""
    variations = set()

    # Adiciona a intenção original
    variations.add(intent)

    # Adiciona templates específicos do serviço
    if service_id in SERVICE_VARIATIONS:
        for template in SERVICE_VARIATIONS[service_id]:
            variations.add(template)

    # Gera variações aplicando transformações
    base_texts = list(variations)
    for _ in range(num_variations):
        text = random.choice(base_texts)

        # Aplica transformações aleatórias
        text = apply_coloquial(text)
        text = apply_typos(text)
        text = add_informal_words(text)
        text = remove_punctuation(text)

        variations.add(text)

    return list(variations)


def generate_test_csv(input_csv: str, output_csv: str, variations_per_service: int = 5):
    """Gera CSV com variações para testes."""
    # Ler CSV original
    with open(input_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        original_data = list(reader)

    # Agrupar por service_id
    services = {}
    for row in original_data:
        service_id = int(row['service_id'])
        if service_id not in services:
            services[service_id] = []
        services[service_id].append(row)

    # Gerar variações
    all_variations = []
    for service_id, rows in services.items():
        # Pega uma linha representativa do serviço
        representative = rows[0]
        service_name = representative['service_name']

        # Gera variações usando templates + transformações
        base_intent = representative['intent']
        variations = generate_variations(base_intent, service_id, variations_per_service)

        for variation in list(variations)[:variations_per_service]:
            all_variations.append({
                'intent': variation,
                'service_id': service_id,
                'service_name': service_name
            })

    # Embaralhar para simular ordem aleatória dos testes
    random.shuffle(all_variations)

    # Salvar novo CSV
    with open(output_csv, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['intent', 'service_id', 'service_name'])
        writer.writeheader()
        writer.writerows(all_variations)

    print(f"✅ Gerado {len(all_variations)} variações em {output_csv}")
    print(f"📊 Distribuição por serviço: ~{variations_per_service} variações cada")


def main():
    import sys

    input_csv = 'assets/intents_pre_loaded.csv'
    output_csv = 'test/synthetic_variations.csv'
    variations = 5

    if len(sys.argv) > 1:
        input_csv = sys.argv[1]
    if len(sys.argv) > 2:
        output_csv = sys.argv[2]
    if len(sys.argv) > 3:
        variations = int(sys.argv[3])

    print(f"📝 Gerando variações sintéticas...")
    print(f"   Input: {input_csv}")
    print(f"   Output: {output_csv}")
    print(f"   Variações por serviço: {variations}\n")

    generate_test_csv(input_csv, output_csv, variations)

    print(f"\n💡 Use este CSV para simular os 80 testes secretos:")
    print(f"   go run test/test_csv.go {output_csv}")


if __name__ == '__main__':
    main()
