defmodule Questify.Lore.Rumor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rumors" do
    field :description, :string
    field :trigger, :string

    field :embedding, Pgvector.Ecto.Vector

    belongs_to :quest, Questify.Games.Quest

    timestamps()
  end

  @doc false
  def changeset(rumor, attrs) do
    rumor
    |> cast(attrs, [:trigger, :description, :embedding, :quest_id])
    |> validate_required([:trigger, :description])
  end
end
