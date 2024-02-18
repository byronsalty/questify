defmodule Questify.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests) do
      add :name, :string
      add :slug, :string
      add :description, :text
      add :creator_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:quests, [:creator_id])
    create unique_index(:quests, [:slug])
  end
end
