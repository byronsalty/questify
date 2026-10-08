import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
#
# Every connection field is overridable via TEST_DB_* so the same config runs
# in Royale worker containers, where Postgres lives at `worker-test-db` (not
# localhost) with its own credentials and a per-worker database name.
config :questify, Questify.Repo,
  username: System.get_env("TEST_DB_USER", "postgres"),
  password: System.get_env("TEST_DB_PASS", "postgres"),
  hostname: System.get_env("TEST_DB_HOST", "localhost"),
  port: String.to_integer(System.get_env("TEST_DB_PORT", "5538")),
  database:
    System.get_env("TEST_DB_NAME") ||
      "questify_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :questify, QuestifyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "R/XNsxjpY3zLv8kCyLA6nWMx4s9BCxE+yxiWLMzIVdcWoXiuKchy15jJQ8Ci+nKx",
  server: false

# In test we don't send emails.
config :questify, Questify.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Keep the suite hermetic: no OpenAI calls for embeddings, Instructor
# completions or image generation.
config :questify, :embeddings_adapter, Questify.Embeddings.Stub
config :questify, :generate_images, false
config :instructor, adapter: Questify.InstructorStub
