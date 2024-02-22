defmodule Questify.Games.Action do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actions" do
    field :command, :string
    field :description, :string
    field :is_terminal, :boolean, default: false

    field :embedding, Pgvector.Ecto.Vector

    belongs_to :quest, Questify.Games.Quest
    belongs_to :from, Questify.Games.Location, foreign_key: :from_id
    belongs_to :to, Questify.Games.Location, foreign_key: :to_id

    timestamps()
  end

  @doc false
  def changeset(action, attrs) do
    action
    |> cast(attrs, [:command, :description, :is_terminal, :quest_id, :from_id, :to_id, :embedding])
    |> validate_required([:command, :description, :is_terminal, :quest_id])
  end
end
