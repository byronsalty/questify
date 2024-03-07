defmodule Questify.Repo.Migrations.CreateThemes do
  use Ecto.Migration

  def change do
    create table(:themes) do
      add :name, :string
      add :description, :text

      timestamps()
    end
  end
end
