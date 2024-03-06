defmodule Questify.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Questify.Games` context.
  """

  @doc """
  Generate a quest.
  """
  def quest_fixture(attrs \\ %{}) do
    attrs =
      if Map.has_key?(attrs, :creator_id) do
        attrs
      else
        user = Questify.AccountsFixtures.user_fixture()
        Map.put(attrs, :creator_id, user.id)
      end

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
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    attrs =
      if Map.has_key?(attrs, :quest_id) do
        attrs
      else
        quest = quest_fixture()
        Map.put(attrs, :quest_id, quest.id)
      end

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
    attrs =
      if Map.has_key?(attrs, :quest_id) do
        attrs
      else
        quest = quest_fixture()
        Map.put(attrs, :quest_id, quest.id)
      end

    attrs =
      if Map.has_key?(attrs, :from_id) do
        attrs
      else
        quest_id = attrs[:quest_id]
        location = location_fixture(%{quest_id: quest_id})
        Map.put(attrs, :from_id, location.id)
      end

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

  @doc """
  Generate a play.
  """
  def play_fixture(attrs \\ %{}) do
    {:ok, play} =
      attrs
      |> Enum.into(%{
        is_complete: true,
        rating: 120.5
      })
      |> Questify.Games.create_play()

    play
  end
end
