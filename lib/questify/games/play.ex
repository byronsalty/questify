defmodule Questify.Games.Play do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "plays" do
    field :is_complete, :boolean, default: false
    field :rating, :float

    belongs_to :quest, Questify.Games.Quest
    belongs_to :location, Questify.Games.Location

    timestamps()
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:is_complete, :rating, :quest_id, :location_id])
    |> validate_required([:is_complete, :quest_id, :location_id])
  end
end
