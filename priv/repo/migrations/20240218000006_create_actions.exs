defmodule Questify.Repo.Migrations.CreateActions do
  use Ecto.Migration

  def change do
    create table(:actions) do
      add :command, :string
      add :description, :text
      add :is_terminal, :boolean, default: false, null: false
      add :from_id, references(:locations, on_delete: :nothing)
      add :to_id, references(:locations, on_delete: :nothing)
      add :quest_id, references(:quests, on_delete: :nothing)

      timestamps()
    end

    create index(:actions, [:from_id])
    create index(:actions, [:to_id])
    create index(:actions, [:quest_id])
  end
end
