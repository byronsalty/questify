defmodule Questify.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :description, :text
      add :img_url, :string
      add :is_terminal, :boolean
      add :quest_id, references(:quests, on_delete: :nothing)

      timestamps()
    end

    create index(:locations, [:quest_id])
  end
end
