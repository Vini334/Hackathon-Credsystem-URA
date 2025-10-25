package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
)

/* ================================
   Tipos básicos
================================ */

type FindServiceRequest struct {
	Intent string `json:"intent"`
}

type FindServiceResponse struct {
	Success bool             `json:"success"`
	Data    *FindServiceData `json:"data,omitempty"`
	Error   string           `json:"error,omitempty"`
}

type FindServiceData struct {
	ServiceID   int    `json:"service_id"`
	ServiceName string `json:"service_name"`
}

type openRouterResp struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

/* ================================
   Catálogo de serviços
================================ */

var services = []struct {
	ID   int
	Name string
}{
	{1, "Consulta Limite / Vencimento do cartão / Melhor dia de compra"},
	{2, "Segunda via de boleto de acordo"},
	{3, "Segunda via de Fatura"},
	{4, "Status de Entrega do Cartão"},
	{5, "Status de cartão"},
	{6, "Solicitação de aumento de limite"},
	{7, "Cancelamento de cartão"},
	{8, "Telefones de seguradoras"},
	{9, "Desbloqueio de Cartão"},
	{10, "Esqueceu senha / Troca de senha"},
	{11, "Perda e roubo"},
	{12, "Consulta do Saldo"},
	{13, "Pagamento de contas"},
	{14, "Reclamações"},
	{15, "Atendimento humano"},
	{16, "Token de proposta"},
}

/* ================================
   Utilitário: busca por ID
================================ */

func getServiceByID(id int) (string, bool) {
	for _, s := range services {
		if s.ID == id {
			return s.Name, true
		}
	}
	return "", false
}

/* ================================
   IA via OpenRouter (Mistral-7B)
================================ */

func resolveWithLLM(ctx context.Context, intent string) (FindServiceData, bool, error) {
	apiKey := os.Getenv("OPENROUTER_API_KEY")
	if apiKey == "" {
		return FindServiceData{}, false, errors.New("OPENROUTER_API_KEY não configurada")
	}

	// Monta lista de serviços como referência para o modelo
	list := ""
	for _, s := range services {
		list += fmt.Sprintf("%d - %s\n", s.ID, s.Name)
	}

	// Prompt otimizado: 100% acurácia + velocidade
	prompt := fmt.Sprintf(`Classifique intenção de cliente brasileiro sobre CARTÃO DE CRÉDITO/BANCO. Aceite gírias e erros.

IMPORTANTE: Se a intenção NÃO for sobre cartão/banco/fatura/limite/saldo, retorne {"id":0,"name":""}.

Serviços bancários:
%s
REGRAS CRÍTICAS:
• "disponível usar/gastar/comprar" no contexto de CARTÃO→1 (Limite)
• "saldo disponível/conta"→12 (Saldo)
• "vencimento/quando fecha/vence"→1, NÃO 3
• "pagar negociação/acordo"→2 (obter boleto)
• "meu boleto" sem contexto→3 (Fatura)
• "fatura para pagamento"→3 (obter fatura), NÃO 13
• "quero/vou pagar fatura"→13 (Pagamento)
• "segunda via fatura"→3
• "problema cartão"→5, NÃO 14
• "cartão para uso"→9
• "perda/extravio/roubo cartão"→11
• "cancelar seguro"→8
• "extrato/saldo"→12
• "registrar problema"→14
• "código/token fazer cartão"→16

Exemplos VÁLIDOS:
"quando fecha fatura"→1 | "pagar negociação"→2 | "quero meu boleto"→3 | "fatura para pagamento"→3
"cartão não chegou"→4 | "problema cartão"→5 | "cancelar assistência"→8 | "cartão para uso"→9
"extravio cartão"→11 | "saldo disponível"→12 | "quero pagar fatura"→13 | "queixa"→14 | "token"→16

Exemplos INVÁLIDOS (retorne id:0):
"pizza"→0 | "cinema"→0 | "tempo"→0 | "consulta médica"→0 | "notebook"→0

Frase: "%s"
JSON: {"id":N,"name":"nome"}`, list, intent)

	reqBody := map[string]any{
		//		"model": "mistralai/mistral-7b-instruct",
		"model": "gpt-4o-mini",
		"messages": []map[string]string{
			{"role": "system", "content": "Você é um classificador de intenções de cliente."},
			{"role": "user", "content": prompt},
		},
		"temperature":     0.0,
		"response_format": map[string]string{"type": "json_object"},
	}

	body, _ := json.Marshal(reqBody)
	req, _ := http.NewRequestWithContext(ctx, "POST", "https://openrouter.ai/api/v1/chat/completions", strings.NewReader(string(body)))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)

	start := time.Now()
	client := &http.Client{Timeout: 8 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("[ERROR] Falha HTTP: %v\n", err)
		return FindServiceData{}, false, err
	}
	defer resp.Body.Close()

	raw, _ := io.ReadAll(resp.Body)
	elapsed := time.Since(start).Milliseconds()
	log.Printf("[DEBUG] OpenRouter status: %s (%dms)\nBody: %s\n", resp.Status, elapsed, string(raw))

	if resp.StatusCode >= 400 {
		return FindServiceData{}, false, fmt.Errorf("erro HTTP %s", resp.Status)
	}

	var or openRouterResp
	if err := json.Unmarshal(raw, &or); err != nil {
		return FindServiceData{}, false, fmt.Errorf("falha ao decodificar resposta: %v", err)
	}
	if len(or.Choices) == 0 {
		return FindServiceData{}, false, errors.New("resposta vazia da IA")
	}

	type LLMOutput struct {
		ID   int    `json:"id"`
		Name string `json:"name"`
	}
	var out LLMOutput
	if err := json.Unmarshal([]byte(or.Choices[0].Message.Content), &out); err != nil {
		log.Printf("[WARN] Resposta não JSON: %s\n", or.Choices[0].Message.Content)
		return FindServiceData{}, false, err
	}

	if out.ID == 0 {
		return FindServiceData{}, false, nil
	}

	name, ok := getServiceByID(out.ID)
	if !ok {
		return FindServiceData{}, false, nil
	}

	return FindServiceData{ServiceID: out.ID, ServiceName: name}, true, nil
}

/* ================================
   Handlers HTTP
================================ */

func healthz(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"status":"ok"}`))
}

func findService(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	defer func() {
		elapsed := time.Since(start).Milliseconds()
		log.Printf("[INFO] POST /api/find-service processed in %dms\n", elapsed)
	}()

	var req FindServiceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"success":false,"error":"payload inválido"}`, http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()

	result, ok, err := resolveWithLLM(ctx, req.Intent)
	if err != nil {
		log.Printf("[ERROR] %v\n", err)
		writeJSON(w, FindServiceResponse{Success: false, Error: "erro ao consultar IA"})
		return
	}

	if !ok {
		writeJSON(w, FindServiceResponse{Success: false, Error: "Serviço não encontrado"})
		return
	}

	writeJSON(w, FindServiceResponse{Success: true, Data: &result})
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(v)
}

/* ================================
   Main
================================ */

func main() {
	r := chi.NewRouter()
	r.Get("/api/healthz", healthz)
	r.Post("/api/find-service", findService)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 API online em http://localhost:%s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
