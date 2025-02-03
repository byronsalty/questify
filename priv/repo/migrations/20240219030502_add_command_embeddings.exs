defmodule Questify.Repo.Migrations.AddCommandEmbeddings do
  use Ecto.Migration

  def change do
    alter table(:actions) do
      add :embedding, :vector, size: 768
    end
  end
end
