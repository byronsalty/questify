#!/bin/bash

# Directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Project root directory (two levels up from script)
PROJECT_ROOT="$( cd "$DIR/../.." && pwd )"

# Check if .env exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "Creating .env file from .env.example..."
    cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
    echo "Created .env file. Please edit it with your actual values."
else
    echo ".env file already exists"
fi

# Function to update or add environment variable
update_env_var() {
    local key=$1
    local value=$2
    local env_file="$PROJECT_ROOT/.env"
    
    if grep -q "^${key}=" "$env_file"; then
        # Update existing variable
        sed -i '' "s|^${key}=.*|${key}=${value}|" "$env_file"
    else
        # Add new variable
        echo "${key}=${value}" >> "$env_file"
    fi
}

# Prompt for Ollama configuration
read -p "Enter Ollama URL [http://192.168.7.227:11434]: " ollama_url
ollama_url=${ollama_url:-http://192.168.7.227:11434}
update_env_var "OLLAMA_URL" "$ollama_url"

read -p "Enter Ollama model [nomic-embed-text]: " ollama_model
ollama_model=${ollama_model:-nomic-embed-text}
update_env_var "OLLAMA_MODEL" "$ollama_model"

# If OpenAI key doesn't exist, prompt for it
if ! grep -q "^OPENAI_API_KEY=" "$PROJECT_ROOT/.env"; then
    read -p "Enter OpenAI API key (press enter to skip): " openai_key
    if [ ! -z "$openai_key" ]; then
        update_env_var "OPENAI_API_KEY" "$openai_key"
    fi
fi

echo
echo "Environment setup complete. Your .env file contains:"
echo "----------------------------------------"
cat "$PROJECT_ROOT/.env"
echo "----------------------------------------"
echo
echo "To load these variables in your shell, run:"
echo "source $PROJECT_ROOT/.env"
