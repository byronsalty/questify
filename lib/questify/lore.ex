defmodule Questify.Lore do
  @moduledoc """
  The Lore context.
  """

  import Ecto.Query, warn: false
  import Pgvector.Ecto.Query
  alias Questify.Repo

  alias Questify.Lore.Rumor
  alias Questify.Games.Location

  def generate_lore_prompt(quest, text) do
    description = """
    GAME:
    #{quest.name}
    #{quest.description}
    """

    lore_prompt = """
    CONTEXT:
    #{description}

    Please give a one paragraph statement about some lore regarding:
    #{text}
    """

    lore_prompt
  end

  def generate_lore_from_text(quest, text) do
    lore_prompt = generate_lore_prompt(quest, text)

    Questify.Text.get_completion(lore_prompt)
  end

  def get_related_lore(location, user_input) do
    related_lore = get_lore_by_text(user_input)

    if Enum.count(related_lore) > 0 do
      IO.puts("Found related lore")
      generate_lore_from_text(location, hd(related_lore).description)
    else
      IO.puts("Did not find lore")
      generate_lore_from_text(location.quest, user_input)
    end
  end

  def generate_rumor(quest) do
    {:ok, gen} =
      Instructor.chat_completion(
        model: "gpt-3.5-turbo",
        response_model: Questify.Lore.RumorGen,
        max_retries: 3,
        messages: [
          %{
            role: "user",
            content: """
            Your purpose is to create rumors to be spread throughout the game world.

            Here is some information about the game world:
            ```
            #{quest.description}
            ```
            """
          }
        ]
      )
      |> IO.inspect(label: "rumor generation")

    Questify.Lore.create_rumor(%{
      "trigger" => gen.trigger,
      "description" => gen.description,
      "quest_id" => quest.id
    })
  end

  def get_lore_by_text(text) do
    embedding = Questify.Embeddings.embed!(text)
    min_distance = 0.20

    Repo.all(
      from l in Location,
        order_by: cosine_distance(l.embedding, ^embedding),
        limit: 1,
        where: cosine_distance(l.embedding, ^embedding) < ^min_distance
    )
  end

  @doc """
  Returns the list of rumors.

  ## Examples

      iex> list_rumors()
      [%Rumor{}, ...]

  """
  def list_rumors do
    Repo.all(Rumor)
  end

  @doc """
  Gets a single rumor.

  Raises `Ecto.NoResultsError` if the Rumor does not exist.

  ## Examples

      iex> get_rumor!(123)
      %Rumor{}

      iex> get_rumor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rumor!(id), do: Repo.get!(Rumor, id)

  @doc """
  Creates a rumor.

  ## Examples

      iex> create_rumor(%{field: value})
      {:ok, %Rumor{}}

      iex> create_rumor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rumor(attrs \\ %{}) do
    # TODO change this order to all changeset to catch issues before embedding
    embedding = Questify.Embeddings.embed!(attrs["trigger"])
    attrs = Map.put(attrs, "embedding", embedding)

    %Rumor{}
    |> Rumor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rumor.

  ## Examples

      iex> update_rumor(rumor, %{field: new_value})
      {:ok, %Rumor{}}

      iex> update_rumor(rumor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rumor(%Rumor{} = rumor, attrs) do
    # TODO change this order to all changeset to catch issues before embedding
    embedding = Questify.Embeddings.embed!(attrs["trigger"])
    attrs = Map.put(attrs, "embedding", embedding)

    rumor
    |> Rumor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rumor.

  ## Examples

      iex> delete_rumor(rumor)
      {:ok, %Rumor{}}

      iex> delete_rumor(rumor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rumor(%Rumor{} = rumor) do
    Repo.delete(rumor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rumor changes.

  ## Examples

      iex> change_rumor(rumor)
      %Ecto.Changeset{data: %Rumor{}}

  """
  def change_rumor(%Rumor{} = rumor, attrs \\ %{}) do
    Rumor.changeset(rumor, attrs)
  end
end
