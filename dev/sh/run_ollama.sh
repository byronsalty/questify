#!/bin/bash

EMBEDDING_MODEL="bge-large"
COMPLETION_MODEL="mistral"

# Check if Ollama is already running
if ! curl -s http://localhost:11434/api/health >/dev/null; then
    echo "Starting Ollama server..."
    echo "WARNING: Ollama will be accessible from other machines. Make sure your firewall is properly configured."
    OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS="*" ollama serve &
    sleep 5  # Wait for server to start
    
    if curl -s http://localhost:11434/api/health >/dev/null; then
        echo "Ollama server started successfully"
        echo "Server is listening on port 11434 (all interfaces)"
    else
        echo "Failed to start Ollama server"
        exit 1
    fi
else
    echo "Ollama server is already running"
fi

# Function to check and pull a model
check_and_pull_model() {
    local model_name=$1
    local model_purpose=$2
    
    if ! ollama list | grep -q "$model_name"; then
        echo "Pulling $model_name model for $model_purpose..."
        ollama pull $model_name
        if [ $? -eq 0 ]; then
            echo "$model_name model pulled successfully"
        else
            echo "Failed to pull $model_name model"
            exit 1
        fi
    else
        echo "$model_name model is already available"
    fi
}

# Pull both models
check_and_pull_model "$EMBEDDING_MODEL" "embeddings"
check_and_pull_model "$COMPLETION_MODEL" "completions"

echo "Ollama is ready with:"
echo "- $EMBEDDING_MODEL for embeddings"
echo "- $COMPLETION_MODEL for completions"
echo "API endpoint available on port 11434"
