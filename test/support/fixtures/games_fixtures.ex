defmodule Questify.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Questify.Games` context.
  """

  @doc """
  Generate a quest.
  """
  def quest_fixture(attrs \\ %{}) do
    {:ok, quest} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        slug: "some slug"
      })
      |> Questify.Games.create_quest()

    quest
  end

  @doc """
  Generate a locations.
  """
  def locations_fixture(attrs \\ %{}) do
    {:ok, locations} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Questify.Games.create_locations()

    locations
  end

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Questify.Games.create_location()

    location
  end

  @doc """
  Generate a action.
  """
  def action_fixture(attrs \\ %{}) do
    {:ok, action} =
      attrs
      |> Enum.into(%{
        command: "some command",
        description: "some description",
        is_terminal: true
      })
      |> Questify.Games.create_action()

    action
  end
end
