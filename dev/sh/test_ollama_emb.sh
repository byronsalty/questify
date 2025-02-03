#!/bin/bash

# Default values
OLLAMA_URL=${OLLAMA_URL:-"http://localhost:11434"}
MODEL=${OLLAMA_MODEL:-"nomic-embed-text"}
TEXT=${1:-"red balloon"}

echo "Testing Ollama embeddings endpoint..."
echo "URL: $OLLAMA_URL"
echo "Model: $MODEL"
echo "Test text: $TEXT"
echo

curl -s "$OLLAMA_URL/api/embeddings" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"$TEXT\"
  }" | jq '
    if .error then
      {error: .error}
    else
      {
        "status": "success",
        "embedding_length": (.embedding | length),
        "first_values": (.embedding | .[:3]),
        "last_values": (.embedding | .[-3:])
      }
    end
  '
