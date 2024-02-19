defmodule Questify.Repo.Migrations.CreatePlays do
  use Ecto.Migration

  def change do
    create table(:plays, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_complete, :boolean, default: false, null: false
      add :rating, :float
      add :quest_id, references(:quests, on_delete: :nothing)
      add :location_id, references(:locations, on_delete: :nothing)

      timestamps()
    end

    create index(:plays, [:quest_id])
    create index(:plays, [:location_id])
  end
end
