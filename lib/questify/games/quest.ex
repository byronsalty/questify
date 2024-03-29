defmodule Questify.Games.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quests" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :img_url, :string
    field :rating, :float, default: 0.0

    belongs_to :creator, Questify.Accounts.User, foreign_key: :creator_id
    belongs_to :theme, Questify.Creator.Theme
    has_many :locations, Questify.Games.Location

    timestamps()
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [:name, :slug, :rating, :description, :img_url, :creator_id, :theme_id])
    |> validate_required([:name, :slug, :description, :creator_id])
    |> unique_constraint(:slug)
  end
end
