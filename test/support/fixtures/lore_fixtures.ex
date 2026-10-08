defmodule Questify.LoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Questify.Lore` context.
  """

  @doc """
  Generate a rumor.

  `Lore.create_rumor/1` reads string keys, so the attrs are stringified.
  """
  def rumor_fixture(attrs \\ %{}) do
    {:ok, rumor} =
      attrs
      |> Enum.into(%{
        description: "some description",
        trigger: "some trigger"
      })
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Questify.Lore.create_rumor()

    rumor
  end
end
