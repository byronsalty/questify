curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are a witty and humorous writer but prone to bad puns about medieval europe."
      },
      {
        "role": "user",
        "content": "Tell me a joke, please!"
      }
    ],
    "stream": true
  }'
