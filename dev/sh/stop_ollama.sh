#!/bin/bash

# Find Ollama process
OLLAMA_PID=$(pgrep ollama)

if [ -n "$OLLAMA_PID" ]; then
    echo "Stopping Ollama (PID: $OLLAMA_PID)..."
    kill $OLLAMA_PID
    
    # Wait for process to stop
    for i in {1..5}; do
        if ! pgrep ollama > /dev/null; then
            echo "Ollama stopped successfully"
            exit 0
        fi
        sleep 1
    done
    
    # If process still running after 5 seconds, force kill
    if pgrep ollama > /dev/null; then
        echo "Ollama still running, force stopping..."
        kill -9 $OLLAMA_PID
        echo "Ollama force stopped"
    fi
else
    echo "Ollama is not running"
fi
