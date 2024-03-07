defmodule Questify.Creator do
  @moduledoc """
  The Creator context.
  """

  import Ecto.Query, warn: false
  import Pgvector.Ecto.Query

  alias Questify.Repo

  alias Questify.Creator.Theme
  alias Questify.Creator.Chunk

  alias Questify.Games


  def get_or_generate_location(quest, name) do
    IO.puts("Creating a location for #{quest.name} - named: #{name}")

    locations = Games.get_location_by_text(quest, name)
    if Enum.count(locations) > 0 do
      hd(locations)
    else
      IO.puts("lets create one!")
      generate_location(quest, name)
    end
  end

  def generate_location_data(quest, name_text) do
    related_chunks = get_theme_chunks(quest.theme, name_text)

    rag_text =
      related_chunks
      |> Enum.map(fn c -> c.body end)
      |> Enum.join("\n")
      |> IO.inspect(label: "related context...")

    {:ok, gen} =
      Instructor.chat_completion(
        model: "gpt-3.5-turbo",
        response_model: Questify.Creator.LocationGen,
        max_retries: 3,
        messages: [
          %{
            role: "user",
            content: """
            Your purpose is to create a Location in the current quest.

            CONTEXT FOR STYLE:
            ```
            #{rag_text}
            ```

            Derive the name of this Location from this user input:
            ```
            #{name_text}
            ```
            """
          }
        ]
      )

    gen
  end

  def generate_location(quest, name_text) do
    gen = generate_location_data(quest, name_text)

    Questify.Games.create_location(%{
      "quest_id" => quest.id,
      "name" => gen.name,
      "description" => gen.description
    })
  end

  # def generate_action(quest, text) do
  #   quest = from_location.quest

  #   [to_location | _] = Questify.Games.get_location_by_text(quest, text)

  #   {:ok, gen} =
  #     Instructor.chat_completion(
  #       model: "gpt-3.5-turbo",
  #       response_model: Questify.Games.ActionGen,
  #       max_retries: 2,
  #       messages: [
  #         %{
  #           role: "user",
  #           content: """
  #           Your purpose is to create a new action that moves a person from their current location
  #           to the new location that they are describing.

  #           Here is some information about the game world:
  #           ```
  #           #{quest.description}
  #           ```

  #           The user is moving from this location:
  #           ```
  #           #{from_location.name} #{from_location.description}
  #           ```

  #           to this location:
  #           ```
  #           #{to_location.name} #{to_location.description}
  #           ```

  #           This is how the user requested the action:
  #           ```
  #           #{text}
  #           ```
  #           """
  #         }
  #       ]
  #     )
  #     |> IO.inspect(label: "location generation")

  #   Questify.Games.create_action(%{
  #     "quest_id" => quest.id,
  #     "from_id" => from_location.id,
  #     "to_id" => to_location.id,
  #     "command" => gen.command,
  #     "description" => gen.description
  #   })
  # end

  @doc """
  Returns the list of themes.

  ## Examples

      iex> list_themes()
      [%Theme{}, ...]

  """
  def list_themes do
    Repo.all(Theme)
  end

  @doc """
  Gets a single theme.

  Raises `Ecto.NoResultsError` if the Theme does not exist.

  ## Examples

      iex> get_theme!(123)
      %Theme{}

      iex> get_theme!(456)
      ** (Ecto.NoResultsError)

  """
  def get_theme!(id), do: Repo.get!(Theme, id)

  def get_theme_by_name!(name), do: Repo.get_by!(Theme, name: name)

  def get_theme_chunks(theme, text) do
    embedding = Questify.Embeddings.embed!(text)

    min_distance = 0.25

    Repo.all(
      from c in Chunk,
        order_by: cosine_distance(c.embedding, ^embedding),
        limit: 5,
        where: cosine_distance(c.embedding, ^embedding) < ^min_distance,
        where: c.theme_id == ^theme.id
    )

  end

  @doc """
  Creates a theme.

  ## Examples

      iex> create_theme(%{field: value})
      {:ok, %Theme{}}

      iex> create_theme(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_theme(attrs \\ %{}) do
    %Theme{}
    |> Theme.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a theme.

  ## Examples

      iex> update_theme(theme, %{field: new_value})
      {:ok, %Theme{}}

      iex> update_theme(theme, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_theme(%Theme{} = theme, attrs) do
    theme
    |> Theme.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a theme.

  ## Examples

      iex> delete_theme(theme)
      {:ok, %Theme{}}

      iex> delete_theme(theme)
      {:error, %Ecto.Changeset{}}

  """
  def delete_theme(%Theme{} = theme) do
    Repo.delete(theme)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking theme changes.

  ## Examples

      iex> change_theme(theme)
      %Ecto.Changeset{data: %Theme{}}

  """
  def change_theme(%Theme{} = theme, attrs \\ %{}) do
    Theme.changeset(theme, attrs)
  end


  # Filter out lines that don't have many word chars
  # Then group 30 lines together to form a 'Chunk'
  # A better strategy would be to do semantic grouping
  def chunk_file(theme, file_path) do
    File.stream!(file_path)
    |> Stream.filter(fn ln ->
      letter_count =
        String.replace(ln, ~r/\W/, "")
        |> String.length()

      letter_count >= 10
    end)
    |> Stream.chunk_every(30)
    |> Stream.each(fn lines ->
      block = Enum.join(lines, "")
      # IO.puts(block)
      create_chunk(%{
        "theme_id" => theme.id,
        "body" => block
      })
    end)
    |> Stream.run()
  end

  @doc """
  Returns the list of chunks.

  ## Examples

      iex> list_chunks()
      [%Chunk{}, ...]

  """
  def list_chunks do
    Repo.all(Chunk)
  end

  @doc """
  Gets a single chunk.

  Raises `Ecto.NoResultsError` if the Chunk does not exist.

  ## Examples

      iex> get_chunk!(123)
      %Chunk{}

      iex> get_chunk!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chunk!(id), do: Repo.get!(Chunk, id)

  @doc """
  Creates a chunk.

  ## Examples

      iex> create_chunk(%{field: value})
      {:ok, %Chunk{}}

      iex> create_chunk(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chunk(attrs \\ %{}) do
    attrs = add_chunk_embedding(attrs)

    %Chunk{}
    |> Chunk.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chunk.

  ## Examples

      iex> update_chunk(chunk, %{field: new_value})
      {:ok, %Chunk{}}

      iex> update_chunk(chunk, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chunk(%Chunk{} = chunk, attrs) do
    attrs = add_chunk_embedding(attrs)

    chunk
    |> Chunk.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chunk.

  ## Examples

      iex> delete_chunk(chunk)
      {:ok, %Chunk{}}

      iex> delete_chunk(chunk)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chunk(%Chunk{} = chunk) do
    Repo.delete(chunk)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chunk changes.

  ## Examples

      iex> change_chunk(chunk)
      %Ecto.Changeset{data: %Chunk{}}

  """
  def change_chunk(%Chunk{} = chunk, attrs \\ %{}) do
    Chunk.changeset(chunk, attrs)
  end

  defp add_chunk_embedding(attrs) do

    embedding = Questify.Embeddings.embed!(attrs["body"])
    Map.put(attrs, "embedding", embedding)
  end
end
