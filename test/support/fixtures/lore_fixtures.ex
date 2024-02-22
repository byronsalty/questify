defmodule Questify.LoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Questify.Lore` context.
  """

  @doc """
  Generate a rumor.
  """
  def rumor_fixture(attrs \\ %{}) do
    {:ok, rumor} =
      attrs
      |> Enum.into(%{
        description: "some description",
        trigger: "some trigger"
      })
      |> Questify.Lore.create_rumor()

    rumor
  end
end
