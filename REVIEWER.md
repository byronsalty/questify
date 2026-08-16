# Reviewer Guidance

## What this project is

Questify is an Elixir/Phoenix Choose-Your-Own-Adventure game used as a teaching codebase for AI/LLM integration patterns. It uses Postgres with pgvector for embeddings, LiveView for the real-time play UI, and calls out to OpenAI/Anthropic APIs for text, image, and RAG generation. There's no regulated data or money movement — the main risk surface is correctness of the AI integration and game-state logic, not compliance.

The repo is organized as a set of branches at increasing AI integration levels (level_0 = no AI, then branches adding embeddings, RAG/lore, streaming text, image generation, agent behaviors). A PR is normally scoped to one branch/level; treat cross-level scope creep as a smell.

## Pay special attention to

- **Vector/embedding dimensionality.** `locations.embedding`, `actions.embedding`, and `chunks.embedding` are `Pgvector.Ecto.Vector` columns tied to a specific model's output size (`lib/questify/embeddings.ex`). A change to the embedding model or embedding_url must keep the stored dimension consistent with existing rows and migrations, or similarity search silently breaks/errors.
- **RAG chunk/embedding consistency.** Anything touching `Questify.Creator` chunk generation should keep the chunk text and its embedding in sync — regenerating one without the other produces stale search results.
- **N+1 queries on game data.** `Games.get_quest!/1` preloads `[:locations, :theme]`; `Games.get_play!/1` preloads `[:quest, :location]` (singular). `:actions` is preloaded separately where needed, e.g. `play_live/play.ex` does `Repo.preload(location, [:actions, :quest])`. New code paths that touch locations/actions/plays should preload the associations they actually need rather than lazily fetching inside loops — don't assume a function above already loaded something it didn't.
- **LiveView process state.** State in `play_live` is per-connection (per player), not global — a fix that reads like it "resets the game" may only be resetting one player's socket assigns.
- **API key handling.** OpenAI/Anthropic keys flow through `Application.get_env(:questify, :openai/...)` from env vars — flag any PR that hardcodes a key, logs a full request/response containing one, or passes user input straight into a prompt without sanitization.
- **Branch-specific divergence.** Since AI levels live on separate branches, don't assume a helper or schema field from another level's branch exists here — verify against this branch's actual code, not the README's description of the full feature set.

## Conventions worth failing a PR over

- `mix compile --warnings-as-errors` — this codebase treats warnings as review-blocking; a PR that compiles with new warnings should fail review even if tests pass.
- `mix format --check-formatted` — formatting is enforced; unformatted diffs should fail review.

## Commands

Nothing beyond the `test_command` configured in `.royale.json` (`mix test`).
