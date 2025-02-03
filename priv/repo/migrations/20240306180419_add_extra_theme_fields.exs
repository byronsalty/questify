defmodule Questify.Repo.Migrations.AddExtraThemeFields do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :theme_id, references(:themes, on_delete: :nothing)
    end

    alter table(:chunks) do
      add :embedding, :vector, size: 1024
    end
  end
end
