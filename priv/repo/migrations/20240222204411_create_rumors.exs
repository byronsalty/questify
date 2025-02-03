defmodule Questify.Repo.Migrations.CreateRumors do
  use Ecto.Migration

  def change do
    create table(:rumors) do
      add :trigger, :string
      add :description, :text

      add :embedding, :vector, size: 1024

      add :quest_id, references(:quests, on_delete: :nothing)

      timestamps()
    end

    create index(:rumors, [:quest_id])
  end
end
