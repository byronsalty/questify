defmodule Questify.Repo.Migrations.AddCommandEmbeddings do
  use Ecto.Migration

  def change do
    alter table(:actions) do
      add :embedding, :vector, size: 1536
    end
  end
end
