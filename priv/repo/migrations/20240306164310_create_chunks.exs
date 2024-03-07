defmodule Questify.Repo.Migrations.CreateChunks do
  use Ecto.Migration

  def change do
    create table(:chunks) do
      add :body, :text
      add :theme_id, references(:themes, on_delete: :nothing)

      timestamps()
    end

    create index(:chunks, [:theme_id])
  end
end
