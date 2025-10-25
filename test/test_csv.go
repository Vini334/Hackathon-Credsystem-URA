package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"time"
)

type TestRequest struct {
	Intent string `json:"intent"`
}

type TestResponse struct {
	Success bool `json:"success"`
	Data    *struct {
		ServiceID   int    `json:"service_id"`
		ServiceName string `json:"service_name"`
	} `json:"data,omitempty"`
	Error string `json:"error,omitempty"`
}

type TestResult struct {
	Intent         string
	ExpectedID     int
	ExpectedName   string
	ActualID       int
	ActualName     string
	Success        bool
	ResponseTimeMs int64
	Error          string
}

func main() {
	apiURL := os.Getenv("API_URL")
	if apiURL == "" {
		apiURL = "http://localhost:8080"
	}

	csvPath := "assets/intents_pre_loaded.csv"
	if len(os.Args) > 1 {
		csvPath = os.Args[1]
	}

	fmt.Printf("🧪 Testando API: %s\n", apiURL)
	fmt.Printf("📄 CSV: %s\n\n", csvPath)

	// Ler CSV
	file, err := os.Open(csvPath)
	if err != nil {
		fmt.Printf("❌ Erro ao abrir CSV: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		fmt.Printf("❌ Erro ao ler CSV: %v\n", err)
		os.Exit(1)
	}

	// Pular header
	if len(records) == 0 {
		fmt.Println("❌ CSV vazio")
		os.Exit(1)
	}
	records = records[1:]

	// Executar testes
	results := make([]TestResult, 0)
	totalTime := int64(0)
	successes := 0
	failures := 0

	fmt.Printf("Executando %d testes...\n\n", len(records))

	for i, record := range records {
		if len(record) < 3 {
			fmt.Printf("⚠️  Linha %d: formato inválido\n", i+2)
			continue
		}

		intent := record[0]
		expectedID, _ := strconv.Atoi(record[1])
		expectedName := record[2]

		// Fazer request
		start := time.Now()
		actualID, actualName, success, errMsg := testIntent(apiURL, intent)
		elapsed := time.Since(start).Milliseconds()
		totalTime += elapsed

		result := TestResult{
			Intent:         intent,
			ExpectedID:     expectedID,
			ExpectedName:   expectedName,
			ActualID:       actualID,
			ActualName:     actualName,
			Success:        success && actualID == expectedID,
			ResponseTimeMs: elapsed,
			Error:          errMsg,
		}
		results = append(results, result)

		if result.Success {
			successes++
			fmt.Printf("✅ [%d/%d] %dms - %s\n", i+1, len(records), elapsed, intent)
		} else {
			failures++
			fmt.Printf("❌ [%d/%d] %dms - %s\n", i+1, len(records), elapsed, intent)
			fmt.Printf("   Esperado: ID %d (%s)\n", expectedID, expectedName)
			fmt.Printf("   Recebido: ID %d (%s)\n", actualID, actualName)
			if errMsg != "" {
				fmt.Printf("   Erro: %s\n", errMsg)
			}
		}
	}

	// Relatório final
	divider := "============================================================"
	fmt.Println("\n" + divider)
	fmt.Printf("📊 RELATÓRIO FINAL\n")
	fmt.Println(divider)
	fmt.Printf("Total de testes: %d\n", len(results))
	fmt.Printf("✅ Sucessos: %d (%.1f%%)\n", successes, float64(successes)/float64(len(results))*100)
	fmt.Printf("❌ Falhas: %d (%.1f%%)\n", failures, float64(failures)/float64(len(results))*100)
	fmt.Printf("⏱️  Tempo médio: %dms\n", totalTime/int64(len(results)))
	fmt.Printf("⏱️  Tempo total: %.2fs\n\n", float64(totalTime)/1000)

	// Calcular score do hackathon
	avgTime := float64(totalTime) / float64(len(results))
	score := (float64(successes) * 10.0) - (float64(failures) * 50.0) - (avgTime * 0.01)
	fmt.Printf("🏆 SCORE ESTIMADO: %.2f pontos\n", score)
	fmt.Printf("   Sucessos: %.0f pts\n", float64(successes)*10.0)
	fmt.Printf("   Falhas: %.0f pts\n", float64(failures)*-50.0)
	fmt.Printf("   Tempo: -%.2f pts\n\n", avgTime*0.01)

	// Salvar relatório detalhado
	saveReport(results, successes, failures, totalTime)

	if failures > 0 {
		os.Exit(1)
	}
}

func testIntent(apiURL, intent string) (int, string, bool, string) {
	reqBody := TestRequest{Intent: intent}
	jsonData, _ := json.Marshal(reqBody)

	resp, err := http.Post(
		apiURL+"/api/find-service",
		"application/json",
		bytes.NewBuffer(jsonData),
	)
	if err != nil {
		return 0, "", false, fmt.Sprintf("HTTP error: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return 0, "", false, fmt.Sprintf("Status %d: %s", resp.StatusCode, string(body))
	}

	var result TestResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return 0, "", false, fmt.Sprintf("JSON decode error: %v", err)
	}

	if !result.Success {
		return 0, "", false, result.Error
	}

	if result.Data == nil {
		return 0, "", false, "data is null"
	}

	return result.Data.ServiceID, result.Data.ServiceName, true, ""
}

func saveReport(results []TestResult, successes, failures int, totalTime int64) {
	file, err := os.Create("test/report.json")
	if err != nil {
		fmt.Printf("⚠️  Não foi possível salvar relatório: %v\n", err)
		return
	}
	defer file.Close()

	report := map[string]interface{}{
		"timestamp":       time.Now().Format(time.RFC3339),
		"total_tests":     len(results),
		"successes":       successes,
		"failures":        failures,
		"accuracy":        float64(successes) / float64(len(results)) * 100,
		"avg_time_ms":     totalTime / int64(len(results)),
		"total_time_ms":   totalTime,
		"estimated_score": (float64(successes) * 10.0) - (float64(failures) * 50.0) - (float64(totalTime)/float64(len(results)) * 0.01),
		"results":         results,
	}

	encoder := json.NewEncoder(file)
	encoder.SetIndent("", "  ")
	encoder.Encode(report)

	fmt.Printf("📄 Relatório salvo em: test/report.json\n")
}
