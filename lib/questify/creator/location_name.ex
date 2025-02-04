defmodule Questify.Creator.LocationName do
  use Ecto.Schema
  use Instructor.Validator
  import Ecto.Changeset

  @doc """
  ## Field Descriptions:
  - name: A name for this location
  """
  @primary_key false
  embedded_schema do
    field(:name, :string)
  end

  @impl true
  def validate_changeset(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, min: 4, max: 30)
  end
end
