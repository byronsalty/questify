defmodule Questify.LoreTest do
  use Questify.DataCase

  alias Questify.Lore

  describe "rumors" do
    alias Questify.Lore.Rumor

    import Questify.LoreFixtures

    @invalid_attrs %{description: nil, trigger: nil}

    test "list_rumors/0 returns all rumors" do
      rumor = rumor_fixture()
      assert Lore.list_rumors() == [rumor]
    end

    test "get_rumor!/1 returns the rumor with given id" do
      rumor = rumor_fixture()
      assert Lore.get_rumor!(rumor.id) == rumor
    end

    test "create_rumor/1 with valid data creates a rumor" do
      valid_attrs = %{description: "some description", trigger: "some trigger"}

      assert {:ok, %Rumor{} = rumor} = Lore.create_rumor(valid_attrs)
      assert rumor.description == "some description"
      assert rumor.trigger == "some trigger"
    end

    test "create_rumor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lore.create_rumor(@invalid_attrs)
    end

    test "update_rumor/2 with valid data updates the rumor" do
      rumor = rumor_fixture()
      update_attrs = %{description: "some updated description", trigger: "some updated trigger"}

      assert {:ok, %Rumor{} = rumor} = Lore.update_rumor(rumor, update_attrs)
      assert rumor.description == "some updated description"
      assert rumor.trigger == "some updated trigger"
    end

    test "update_rumor/2 with invalid data returns error changeset" do
      rumor = rumor_fixture()
      assert {:error, %Ecto.Changeset{}} = Lore.update_rumor(rumor, @invalid_attrs)
      assert rumor == Lore.get_rumor!(rumor.id)
    end

    test "delete_rumor/1 deletes the rumor" do
      rumor = rumor_fixture()
      assert {:ok, %Rumor{}} = Lore.delete_rumor(rumor)
      assert_raise Ecto.NoResultsError, fn -> Lore.get_rumor!(rumor.id) end
    end

    test "change_rumor/1 returns a rumor changeset" do
      rumor = rumor_fixture()
      assert %Ecto.Changeset{} = Lore.change_rumor(rumor)
    end
  end
end
