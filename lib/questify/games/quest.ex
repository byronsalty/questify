defmodule Questify.Games.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quests" do
    field :name, :string
    field :description, :string
    field :slug, :string

    belongs_to :creator, Questify.Accounts.User, foreign_key: :creator_id
    has_many :locations, Questify.Games.Location

    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [:name, :slug, :description, :creator_id])
    |> validate_required([:name, :slug, :description, :creator_id])
    |> unique_constraint(:slug)
  end
end
