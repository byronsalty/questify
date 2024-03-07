defmodule Questify.Creator.Chunk do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chunks" do
    field :body, :string

    field :embedding, Pgvector.Ecto.Vector

    belongs_to :theme, Questify.Creator.Theme

    timestamps()
  end

  @doc false
  def changeset(chunk, attrs) do
    chunk
    |> cast(attrs, [:body, :theme_id, :embedding])
    |> validate_required([:body, :theme_id])
  end
end
