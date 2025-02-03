defmodule Questify.Repo.Migrations.AddLocationEmbedding do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :embedding, :vector, size: 1024
    end
  end
end
