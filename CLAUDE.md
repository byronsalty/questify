# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Questify is an Elixir/Phoenix text-based adventure game demonstrating AI/LLM integration at various levels. It's a Choose Your Own Adventure style game with locations, actions, and quest progression.

## Essential Commands

### Development
```bash
# Start development database (Docker recommended)
dev/sh/runDB.sh

# Run development server
mix phx.server
# Or with interactive shell
iex -S mix phx.server

# Access at http://localhost:4500
```

### Database
```bash
mix ecto.reset    # Drop, create, migrate, seed
mix ecto.migrate  # Run pending migrations
mix ecto.setup    # Create, migrate, seed
```

### Testing
```bash
mix test                          # Run all tests
mix test test/questify/games_test.exs  # Run specific test
mix test --cover                  # With coverage
```

### Code Quality
```bash
mix format        # Format code
mix compile --warnings-as-errors  # Check for warnings
```

### Assets
```bash
mix assets.build   # Build for development
mix assets.deploy  # Build and minify for production
```

## Architecture Essentials

### Core Contexts and Their Responsibilities

**Games Context** (`lib/questify/games/`)
- Manages quests, locations, actions, and play sessions
- Core game logic and state management
- Database queries for game data

**Creator Context** (`lib/questify/creator/`)
- AI-powered content generation
- Manages themes and text chunks for RAG
- Generates locations and actions dynamically

**Embeddings Module** (`lib/questify/embeddings.ex`)
- Vector embedding generation and storage
- Semantic search functionality
- Integration with pgvector

**LiveView Modules** (`lib/questify_web/live/`)
- `play_live/` - Real-time game interface
- `admin/` - Quest/location/action management
- All use server-side rendering with WebSocket updates

### Database Schema with Vectors

The app uses PostgreSQL with pgvector extension:
- **locations** and **actions** tables have `embedding` vector columns (1536 dimensions)
- **chunks** table stores text with embeddings for RAG
- Semantic search via `embedding <-> query_embedding` operators

### AI Integration Points

1. **Text Generation**: `TextHandler` → OpenAI/Anthropic APIs
2. **Image Generation**: `ImageHandler` → DALL-E/Stable Diffusion → S3
3. **Embeddings**: `Embeddings` module → OpenAI embeddings API
4. **RAG System**: Chunks + vector search for context-aware generation
5. **Agent Behaviors**: `AgentHandler` for autonomous actions

## Development Patterns

### Phoenix Contexts
Always work through context modules (Games, Creator, Accounts) rather than directly with schemas.

### LiveView State Management
- Use `assign` for state
- Handle events with `handle_event/3`
- Real-time updates via `Phoenix.PubSub`

### Database Transactions
Use `Ecto.Multi` for complex operations:
```elixir
Multi.new()
|> Multi.insert(:quest, quest_changeset)
|> Multi.insert(:location, location_changeset)
|> Repo.transaction()
```

### Error Handling
- Use `{:ok, result}` / `{:error, reason}` tuples
- Handle errors in LiveView with `put_flash`

## Testing Approach

### Test Helpers
- `test/support/fixtures/` contains factory functions
- Use `Questify.GamesFixtures.quest_fixture()` for test data

### LiveView Testing
```elixir
{:ok, view, _html} = live(conn, ~p"/play/#{play.id}")
view |> element("button", "Choose") |> render_click()
```

## Common Pitfalls to Avoid

1. **Don't forget pgvector setup** - Database must have vector extension
2. **LiveView process state** - State is per-connection, not global
3. **Async operations** - Use `Task` for background work, update via PubSub
4. **N+1 queries** - Preload associations: `Repo.preload(quest, [:locations, :actions])`

## AI/LLM Features by Branch

- **main/level_0**: Base game without AI
- **level_1**: Simple API integration
- **level_2**: RAG with embeddings
- **level_3**: Agent-based behaviors

When working with AI features, check which level is active and ensure proper API keys are configured in `.env`.

## Performance Considerations

- Use database indexes on foreign keys and frequently queried fields
- Vector similarity searches can be slow on large datasets - consider limiting scope
- LiveView reduces client-server traffic but maintains server-side state per connection
- Use `async` assigns for slow-loading data

## Security Notes

- User authentication uses `bcrypt_elixir` with session tokens
- CSRF protection enabled by default
- Never commit API keys - use environment variables
- Sanitize user input before passing to AI APIs