#!/bin/bash

MODEL_NAME="nomic-embed-text"

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

# Check if the model exists, if not pull it
if ! ollama list | grep -q "$MODEL_NAME"; then
    echo "Pulling $MODEL_NAME model..."
    ollama pull $MODEL_NAME
    if [ $? -eq 0 ]; then
        echo "$MODEL_NAME model pulled successfully"
    else
        echo "Failed to pull $MODEL_NAME model"
        exit 1
    fi
else
    echo "$MODEL_NAME model is already available"
fi

echo "Ollama is ready to serve embeddings with $MODEL_NAME"
echo "API endpoint available on port 11434"
