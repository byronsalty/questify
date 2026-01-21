# Default: show available commands
default:
    @just --list

# ================================================================================
# SETUP
# ================================================================================

# Install dependencies, setup database, and build assets
setup:
    mix setup

# ================================================================================
# DATABASE
# ================================================================================

# Start local PostgreSQL container
db-start:
    dev/sh/runDB.sh

# Stop local PostgreSQL container
db-stop:
    docker stop questify_db

# Reset database (drop, create, migrate, seed)
db-reset:
    mix ecto.reset

# Run database migrations
migrate:
    mix ecto.migrate

# Connect to local database via psql
db-connect:
    dev/sh/connectDB.sh

# Connect to production database via psql
db-connect-prod:
    dev/sh/connectDB_prod.sh

# ================================================================================
# DEVELOPMENT
# ================================================================================

# Start Phoenix development server
phx-dev:
    mix phx.server

# Start interactive Elixir shell with Phoenix
iex:
    iex -S mix phx.server

# ================================================================================
# TESTING
# ================================================================================

# Run Phoenix tests
phx-test:
    mix test

# ================================================================================
# DEPLOYMENT
# ================================================================================

# View production logs
logs:
    fly logs

# Deploy to production
deploy:
    fly deploy
