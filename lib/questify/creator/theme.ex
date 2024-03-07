defmodule Questify.Creator.Theme do
  use Ecto.Schema
  import Ecto.Changeset

  schema "themes" do
    field :name, :string
    field :description, :string

    has_many :quests, Questify.Games.Quest

    timestamps()
  end

  @doc false
  def changeset(theme, attrs) do
    theme
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
