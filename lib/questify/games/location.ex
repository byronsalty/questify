defmodule Questify.Games.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :description, :string
    field :img_url, :string
    field :is_terminal, :boolean, default: false
    field :is_starting, :boolean, default: false

    field :embedding, Pgvector.Ecto.Vector
    field :min_distance, :float, virtual: true

    belongs_to :quest, Questify.Games.Quest
    has_many :actions, Questify.Games.Action, foreign_key: :from_id

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [
      :name,
      :description,
      :img_url,
      :is_terminal,
      :is_starting,
      :quest_id,
      :embedding
    ])
    |> validate_required([:name, :description, :quest_id])
  end
end
