defmodule Questify.CreatorTest do
  use Questify.DataCase

  alias Questify.Creator

  describe "themes" do
    alias Questify.Creator.Theme

    import Questify.CreatorFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_themes/0 returns all themes" do
      theme = theme_fixture()
      assert Creator.list_themes() == [theme]
    end

    test "get_theme!/1 returns the theme with given id" do
      theme = theme_fixture()
      assert Creator.get_theme!(theme.id) == theme
    end

    test "create_theme/1 with valid data creates a theme" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Theme{} = theme} = Creator.create_theme(valid_attrs)
      assert theme.name == "some name"
      assert theme.description == "some description"
    end

    test "create_theme/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Creator.create_theme(@invalid_attrs)
    end

    test "update_theme/2 with valid data updates the theme" do
      theme = theme_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Theme{} = theme} = Creator.update_theme(theme, update_attrs)
      assert theme.name == "some updated name"
      assert theme.description == "some updated description"
    end

    test "update_theme/2 with invalid data returns error changeset" do
      theme = theme_fixture()
      assert {:error, %Ecto.Changeset{}} = Creator.update_theme(theme, @invalid_attrs)
      assert theme == Creator.get_theme!(theme.id)
    end

    test "delete_theme/1 deletes the theme" do
      theme = theme_fixture()
      assert {:ok, %Theme{}} = Creator.delete_theme(theme)
      assert_raise Ecto.NoResultsError, fn -> Creator.get_theme!(theme.id) end
    end

    test "change_theme/1 returns a theme changeset" do
      theme = theme_fixture()
      assert %Ecto.Changeset{} = Creator.change_theme(theme)
    end
  end

  describe "chunks" do
    alias Questify.Creator.Chunk

    import Questify.CreatorFixtures

    @invalid_attrs %{body: nil}

    test "list_chunks/0 returns all chunks" do
      chunk = chunk_fixture()
      assert Creator.list_chunks() == [chunk]
    end

    test "get_chunk!/1 returns the chunk with given id" do
      chunk = chunk_fixture()
      assert Creator.get_chunk!(chunk.id) == chunk
    end

    test "create_chunk/1 with valid data creates a chunk" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %Chunk{} = chunk} = Creator.create_chunk(valid_attrs)
      assert chunk.body == "some body"
    end

    test "create_chunk/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Creator.create_chunk(@invalid_attrs)
    end

    test "update_chunk/2 with valid data updates the chunk" do
      chunk = chunk_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Chunk{} = chunk} = Creator.update_chunk(chunk, update_attrs)
      assert chunk.body == "some updated body"
    end

    test "update_chunk/2 with invalid data returns error changeset" do
      chunk = chunk_fixture()
      assert {:error, %Ecto.Changeset{}} = Creator.update_chunk(chunk, @invalid_attrs)
      assert chunk == Creator.get_chunk!(chunk.id)
    end

    test "delete_chunk/1 deletes the chunk" do
      chunk = chunk_fixture()
      assert {:ok, %Chunk{}} = Creator.delete_chunk(chunk)
      assert_raise Ecto.NoResultsError, fn -> Creator.get_chunk!(chunk.id) end
    end

    test "change_chunk/1 returns a chunk changeset" do
      chunk = chunk_fixture()
      assert %Ecto.Changeset{} = Creator.change_chunk(chunk)
    end
  end
end
