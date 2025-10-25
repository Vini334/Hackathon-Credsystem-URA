# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Go-based intent classification service that uses LLM (via OpenRouter) to map customer service requests in Portuguese to predefined service categories. The service exposes an HTTP API for classifying customer intents.

## Architecture

### Single-File Structure
The entire application is contained in `main.go` with these key components:

1. **HTTP Server**: Chi router with two endpoints:
   - `GET /api/healthz`: Health check endpoint
   - `POST /api/find-service`: Main intent classification endpoint

2. **LLM Integration**:
   - Uses OpenRouter API (currently configured with `gpt-4o-mini` model, though code references `mistral-7b-instruct`)
   - Function `resolveWithLLM()` handles all LLM communication
   - Enforces JSON response format via `response_format: json_object`
   - 8-second timeout for LLM requests

3. **Service Catalog**:
   - Hardcoded array of 16 service types in Portuguese (lines 49-69)
   - Services range from card queries to human support
   - LLM maps user intent to service ID + name

### Request Flow
1. Client sends POST to `/api/find-service` with `{"intent": "user query in Portuguese"}`
2. Server builds prompt with service catalog and user intent
3. LLM classifies intent and returns `{"id": number, "name": string}`
4. Server validates ID against catalog and returns result
5. If no match: returns `{"success": false, "error": "intenção não encontrada"}`

## Development Commands

### Using Makefile (Recommended)
```bash
make help              # Show all available commands
make run               # Start server on port 8080
make test              # Test 93 base intents
make generate-variations  # Generate synthetic test variations
make benchmark         # Run full hackathon simulation
make quick-test        # Fast test (first round only)
make check-api         # Verify API is online
```

### Running the Service
```bash
go run main.go
# Service starts on port 8080 (or PORT env variable)
```

### Environment Variables
- `OPENROUTER_API_KEY`: Required for LLM API access
- `PORT`: Optional server port (defaults to 8080)

### Testing

#### Quick API Test
```bash
# Health check
curl http://localhost:8080/api/healthz

# Test intent classification
curl -X POST http://localhost:8080/api/find-service \
  -H "Content-Type: application/json" \
  -d '{"intent": "quero aumentar meu limite"}'
```

#### Full Test Suite
```bash
# Test with 93 base intents
go run test/test_csv.go assets/intents_pre_loaded.csv

# Generate synthetic variations (simulates secret 80 tests)
python3 test/generate_variations.py

# Full benchmark (simulates hackathon conditions)
./test/run_benchmark.sh
```

### Check OpenRouter Credits
```bash
python3 utils/check_limit_openrouter.py
# or
export OPENROUTER_API_KEY=your_key
python3 utils/check_limit_openrouter.py
```

### Building
```bash
go build -o ura-intent main.go
# or
make build  # Creates bin/ura-intent
```

## Key Implementation Details

- **Timeout Strategy**: 8-second context timeout for both LLM calls and HTTP client
- **Error Handling**: LLM errors return generic "erro ao consultar IA" to client; detailed errors logged
- **Logging**: Comprehensive debug logging including response times and raw LLM responses
- **Model Selection**: Code shows `gpt-4o-mini` in use but has commented reference to `mistral-7b-instruct`
- **Zero Temperature**: Uses `temperature: 0.0` for deterministic classification

## Prompt Optimization (main.go:101-130)

The prompt has been optimized for Brazilian Portuguese variations:
- Handles colloquialisms ("vo", "tá", "num", "cade", "kero")
- Tolerates typos and transcription errors
- Understands abbreviations ("pq", "vc", "tb")
- Includes 5 concrete examples of variations
- Instructs model to analyze INTENT, not just keywords

## Test Infrastructure

### Scripts Available
- `test/test_csv.go`: Go script to validate intents from CSV
- `test/generate_variations.py`: Python script to generate synthetic variations with Brazilian colloquialisms
- `test/run_benchmark.sh`: Full hackathon simulation (93 base + 80 variations)
- `utils/check_limit_openrouter.py`: Check remaining OpenRouter credits

### Scoring System (Hackathon Formula)
```
Score = (Successes × 10.0) - (Failures × 50.0) - (Avg_Time_ms × 0.01)
```

**Key Insight**: Failures are 5000x more expensive than milliseconds!
- 1 failure = -50 pts = 5000ms penalty
- Prioritize accuracy over speed

### Test Files
- `assets/intents_pre_loaded.csv`: 93 base intents with variations
- `test/synthetic_variations.csv`: Generated variations simulating colloquial speech
- `test/report.json`: Detailed test results with timing and accuracy
