defmodule Questify.Games.ActionGen do
  use Ecto.Schema
  use Instructor.Validator
  import Ecto.Changeset

  @doc """
  ## Field Descriptions:
  - description: The description of the movement from one location to the other and what happens to them.
  - trigger: A phrase that someone might to trigger this action.
  """
  @primary_key false
  embedded_schema do
    field(:description, :string)
    field(:command, :string)
  end

  @impl true
  def validate_changeset(changeset) do
    changeset
    |> validate_required([:description, :command])
    |> validate_length(:command, min: 8, max: 30)
  end
end
