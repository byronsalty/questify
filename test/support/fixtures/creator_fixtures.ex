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

  `Creator.create_chunk/1` reads string keys, so the attrs are stringified.
  """
  def chunk_fixture(attrs \\ %{}) do
    attrs =
      if Map.has_key?(attrs, :theme_id) do
        attrs
      else
        Map.put(attrs, :theme_id, theme_fixture().id)
      end

    {:ok, chunk} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Map.new(fn {k, v} -> {to_string(k), v} end)
      |> Questify.Creator.create_chunk()

    chunk
  end
end
