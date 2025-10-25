#!/usr/bin/env python3
"""
Script para consultar créditos restantes na OpenRouter.
Útil para monitorar o limite de $3 durante o hackathon.
"""

import os
import sys
import requests
from datetime import datetime


def check_credits(api_key: str):
    """Consulta créditos restantes na conta OpenRouter."""

    url = "https://openrouter.ai/api/v1/auth/key"
    headers = {
        "Authorization": f"Bearer {api_key}",
    }

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()

        data = response.json()

        # Extrair informações
        limit = data.get("data", {}).get("limit", 0)
        usage = data.get("data", {}).get("usage", 0)
        remaining = limit - usage
        percentage_used = (usage / limit * 100) if limit > 0 else 0

        # Exibir informações
        print("=" * 60)
        print("💰 CRÉDITOS OPENROUTER")
        print("=" * 60)
        print(f"📊 Limite total:     ${limit:.2f}")
        print(f"📉 Usado:            ${usage:.2f} ({percentage_used:.1f}%)")
        print(f"✅ Disponível:       ${remaining:.2f}")
        print("=" * 60)

        # Avisos
        if percentage_used > 90:
            print("⚠️  ATENÇÃO: Você já usou mais de 90% dos créditos!")
        elif percentage_used > 75:
            print("⚠️  ATENÇÃO: Você já usou mais de 75% dos créditos!")
        elif percentage_used > 50:
            print("💡 Você já usou mais de 50% dos créditos.")
        else:
            print("✅ Créditos em nível bom!")

        print()
        print(f"🕐 Consultado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()

        # Estimativa de requests restantes
        avg_cost_per_request = 0.0003  # Estimativa para gpt-4o-mini
        estimated_requests = int(remaining / avg_cost_per_request)
        print(f"📈 Estimativa de requests restantes: ~{estimated_requests}")
        print(f"   (baseado em custo médio de ${avg_cost_per_request:.4f}/request)")
        print()

        return True

    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            print("❌ Erro: API Key inválida!")
        else:
            print(f"❌ Erro HTTP {e.response.status_code}: {e.response.text}")
        return False

    except Exception as e:
        print(f"❌ Erro ao consultar API: {e}")
        return False


def main():
    # Tentar obter API key de variável de ambiente
    api_key = os.getenv("OPENROUTER_API_KEY")

    # Se não estiver na env, pedir ao usuário
    if not api_key:
        if len(sys.argv) > 1:
            api_key = sys.argv[1]
        else:
            print("🔑 Por favor, forneça sua API Key da OpenRouter:")
            print()
            print("Opção 1 - Via argumento:")
            print("  python3 utils/check_limit_openrouter.py sua_api_key")
            print()
            print("Opção 2 - Via variável de ambiente:")
            print("  export OPENROUTER_API_KEY=sua_api_key")
            print("  python3 utils/check_limit_openrouter.py")
            print()
            sys.exit(1)

    check_credits(api_key)


if __name__ == "__main__":
    main()
