#!/bin/bash

# Load environment variables
if [ -f ../../.env ]; then
    source ../../.env
fi

# Check if OLLAMA_URL is set
if [ -z "$OLLAMA_URL" ]; then
    echo "Error: OLLAMA_URL environment variable is not set"
    exit 1
fi

# Test prompt
PROMPT="Write a short story about a magical quest in 2-3 sentences."

echo "Testing Ollama completion with mistral model..."
echo "Prompt: $PROMPT"
echo "Sending request to: $OLLAMA_URL/api/generate"
echo

# Make the API call
curl -X POST "$OLLAMA_URL/api/generate" \
     -H 'Content-Type: application/json' \
     -d "{
         \"model\": \"mistral\",
         \"prompt\": \"$PROMPT\",
         \"stream\": false
     }"

echo -e "\n\nTest complete!"
