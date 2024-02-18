defmodule Questify.GamesTest do
  use Questify.DataCase

  alias Questify.Games

  describe "quests" do
    alias Questify.Games.Quest

    import Questify.GamesFixtures

    @invalid_attrs %{name: nil, description: nil, slug: nil}

    test "list_quests/0 returns all quests" do
      quest = quest_fixture()
      assert Games.list_quests() == [quest]
    end

    test "get_quest!/1 returns the quest with given id" do
      quest = quest_fixture()
      assert Games.get_quest!(quest.id) == quest
    end

    test "create_quest/1 with valid data creates a quest" do
      valid_attrs = %{name: "some name", description: "some description", slug: "some slug"}

      assert {:ok, %Quest{} = quest} = Games.create_quest(valid_attrs)
      assert quest.name == "some name"
      assert quest.description == "some description"
      assert quest.slug == "some slug"
    end

    test "create_quest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_quest(@invalid_attrs)
    end

    test "update_quest/2 with valid data updates the quest" do
      quest = quest_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", slug: "some updated slug"}

      assert {:ok, %Quest{} = quest} = Games.update_quest(quest, update_attrs)
      assert quest.name == "some updated name"
      assert quest.description == "some updated description"
      assert quest.slug == "some updated slug"
    end

    test "update_quest/2 with invalid data returns error changeset" do
      quest = quest_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_quest(quest, @invalid_attrs)
      assert quest == Games.get_quest!(quest.id)
    end

    test "delete_quest/1 deletes the quest" do
      quest = quest_fixture()
      assert {:ok, %Quest{}} = Games.delete_quest(quest)
      assert_raise Ecto.NoResultsError, fn -> Games.get_quest!(quest.id) end
    end

    test "change_quest/1 returns a quest changeset" do
      quest = quest_fixture()
      assert %Ecto.Changeset{} = Games.change_quest(quest)
    end
  end

  describe "locations" do
    alias Questify.Games.Location

    import Questify.GamesFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Games.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Games.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Location{} = location} = Games.create_location(valid_attrs)
      assert location.name == "some name"
      assert location.description == "some description"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Location{} = location} = Games.update_location(location, update_attrs)
      assert location.name == "some updated name"
      assert location.description == "some updated description"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_location(location, @invalid_attrs)
      assert location == Games.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Games.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Games.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Games.change_location(location)
    end
  end

  describe "actions" do
    alias Questify.Games.Action

    import Questify.GamesFixtures

    @invalid_attrs %{command: nil, description: nil, is_terminal: nil}

    test "list_actions/0 returns all actions" do
      action = action_fixture()
      assert Games.list_actions() == [action]
    end

    test "get_action!/1 returns the action with given id" do
      action = action_fixture()
      assert Games.get_action!(action.id) == action
    end

    test "create_action/1 with valid data creates a action" do
      valid_attrs = %{command: "some command", description: "some description", is_terminal: true}

      assert {:ok, %Action{} = action} = Games.create_action(valid_attrs)
      assert action.command == "some command"
      assert action.description == "some description"
      assert action.is_terminal == true
    end

    test "create_action/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_action(@invalid_attrs)
    end

    test "update_action/2 with valid data updates the action" do
      action = action_fixture()
      update_attrs = %{command: "some updated command", description: "some updated description", is_terminal: false}

      assert {:ok, %Action{} = action} = Games.update_action(action, update_attrs)
      assert action.command == "some updated command"
      assert action.description == "some updated description"
      assert action.is_terminal == false
    end

    test "update_action/2 with invalid data returns error changeset" do
      action = action_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_action(action, @invalid_attrs)
      assert action == Games.get_action!(action.id)
    end

    test "delete_action/1 deletes the action" do
      action = action_fixture()
      assert {:ok, %Action{}} = Games.delete_action(action)
      assert_raise Ecto.NoResultsError, fn -> Games.get_action!(action.id) end
    end

    test "change_action/1 returns a action changeset" do
      action = action_fixture()
      assert %Ecto.Changeset{} = Games.change_action(action)
    end
  end
end
