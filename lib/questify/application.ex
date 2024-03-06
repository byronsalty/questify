defmodule Questify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      QuestifyWeb.Telemetry,
      # Start the Ecto repository
      Questify.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Questify.PubSub},
      # Start Finch
      {Finch, name: Questify.Finch},
      # Start the Endpoint (http/https)
      QuestifyWeb.Endpoint,
      Questify.ImageHandler,
      Questify.TextHandler
      # Start a worker by calling: Questify.Worker.start_link(arg)
      # {Questify.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Questify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuestifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
