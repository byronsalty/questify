defmodule Questify.Lore.RumorGen do
  use Ecto.Schema
  use Instructor.Validator

  @doc """
  ## Field Descriptions:
  - description: The actual rumor about this world.
  - trigger: A phrase that someone might say to reveal this rumor.
  """
  @primary_key false
  embedded_schema do
    field(:description, :string)
    field(:trigger, :string)
  end

  # @impl true
  # def validate_changeset(changeset) do
  #   changeset
  #   |> Ecto.Changeset.is_required(:description
  # end
end
