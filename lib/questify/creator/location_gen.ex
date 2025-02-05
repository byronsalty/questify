defmodule Questify.Creator.LocationGen do
  use Ecto.Schema
  use Instructor
  use Instructor.Validator
  import Ecto.Changeset

  @llm_doc """
  ## Field Descriptions:
  - description: A vivid and visual description of this location.
  - name: A name for this location
  """
  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:description, :string)
  end

  @impl true
  def validate_changeset(changeset) do
    changeset
    |> validate_required([:name, :description])
    |> validate_length(:name, min: 4, max: 30)
    |> validate_length(:description, min: 40, max: 750)
  end
end
