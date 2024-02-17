defmodule Questify.Repo do
  use Ecto.Repo,
    otp_app: :questify,
    adapter: Ecto.Adapters.Postgres
end
