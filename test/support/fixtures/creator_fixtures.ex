defmodule Questify.CreatorFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Questify.Creator` context.
  """

  @doc """
  Generate a theme.
  """
  def theme_fixture(attrs \\ %{}) do
    {:ok, theme} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Questify.Creator.create_theme()

    theme
  end

  @doc """
  Generate a chunk.
  """
  def chunk_fixture(attrs \\ %{}) do
    {:ok, chunk} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Questify.Creator.create_chunk()

    chunk
  end
end
