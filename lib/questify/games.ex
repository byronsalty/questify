defmodule Questify.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  import Pgvector.Ecto.Query

  alias Questify.Repo

  alias Questify.Games.Quest
  alias Questify.ImageHandler

  @doc """
  Returns the list of quests.

  ## Examples

      iex> list_quests()
      [%Quest{}, ...]

  """
  def list_quests do
    Quest
    |> order_by(desc: :rating)
    |> Repo.all()
  end

  def list_quests_by_user(user) do
    Quest
    |> where([q], q.creator_id == ^user.id)
    |> order_by(desc: :rating)
    |> Repo.all()
  end

  @doc """
  Gets a single quest.

  Raises `Ecto.NoResultsError` if the Quest does not exist.

  ## Examples

      iex> get_quest!(123)
      %Quest{}

      iex> get_quest!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quest!(id), do: Repo.get!(Quest, id) |> Repo.preload([:locations, :theme])

  def get_quest_by_slug!(slug), do: Repo.get_by!(Quest, slug: slug) |> Repo.preload([:locations, :theme])

  @spec create_quest(
          :invalid
          | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: any()
  @doc """
  Creates a quest.

  ## Examples

      iex> create_quest(%{field: value})
      {:ok, %Quest{}}

      iex> create_quest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quest(attrs \\ %{}) do
    %Quest{}
    |> Quest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quest.

  ## Examples

      iex> update_quest(quest, %{field: new_value})
      {:ok, %Quest{}}

      iex> update_quest(quest, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quest(%Quest{} = quest, attrs) do
    quest
    |> Quest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quest.

  ## Examples

      iex> delete_quest(quest)
      {:ok, %Quest{}}

      iex> delete_quest(quest)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quest(%Quest{} = quest) do
    Repo.delete(quest)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quest changes.

  ## Examples

      iex> change_quest(quest)
      %Ecto.Changeset{data: %Quest{}}

  """
  def change_quest(%Quest{} = quest, attrs \\ %{}) do
    Quest.changeset(quest, attrs)
  end

  alias Questify.Games.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  def get_location_by_text(quest, text) do
    embedding = Questify.Embeddings.embed!(text)
    min_distance = 0.15

    Repo.all(
      from l in Location,
        order_by: cosine_distance(l.embedding, ^embedding),
        limit: 1,
        where: cosine_distance(l.embedding, ^embedding) < ^min_distance,
        where: l.quest_id == ^quest.id
    )
  end

  # def get_location_action_options(location) do
  #   location.actions
  #     |> Enum.with_index(fn action, ind -> {ind + 1, action.command, action.id} end)
  # end

  def get_location_action_hint(location) do
    # action_options = get_location_action_options(location)

    action_description =
      location.actions
      |> Enum.map(fn action -> "#{action.command}, " end)
      |> Enum.join("\n ")

    action_description
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    attrs = add_location_embedding(attrs)

    case Repo.insert(Location.changeset(%Location{}, attrs)) do
      {:ok, location} ->
        if is_nil(location.img_url) do
          hash = create_hash(location.description)
          {_url, filename} = ImageHandler.create_img_url(hash)

          prompt = """
          CONTEXT
          Generate an image portraying the following scene for a retro adventure video game.
          DESCRIPTION
          #{location.description}
          """

          ImageHandler.generate_image(location.id, hash, filename, prompt)

          IO.inspect(location, label: "going to add img url")

          # update_location_no_gen(location, %{img_url: url})
          # |> IO.inspect(label: "updated location")
        end

        IO.inspect(location, label: "location after if in create")

        {:ok, location}
      other ->
        other
    end
  end

  defp create_hash(words) do
    :crypto.hash(:md5, words) |> Base.encode16(case: :lower)
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    attrs = add_location_embedding(attrs)

    case Repo.update(Location.changeset(location, attrs)) do
      {:ok, location} ->
        hash = create_hash(location.description)
        {url, filename} = ImageHandler.create_img_url(hash)

        if location.img_url != url do

          prompt = """
          CONTEXT
          Generate an image portraying the following scene for a retro adventure video game.
          DESCRIPTION
          #{location.description}
          """

          ImageHandler.generate_image(location.id, hash, filename, prompt)

          # update_location_no_gen(location, %{img_url: url})
        end

      other ->
        other
    end
  end

  def update_location_no_gen(%Location{} = location, attrs) do
    Repo.update(Location.changeset(location, attrs))
  end

  defp add_location_embedding(attrs) do
    IO.inspect(attrs, label: "attrs before location embedding")

    location_text = "#{attrs["name"]}"

    embedding = Questify.Embeddings.embed!(location_text)
    Map.put(attrs, "embedding", embedding)
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  alias Questify.Games.Action

  @doc """
  Returns the list of actions.

  ## Examples

      iex> list_actions()
      [%Action{}, ...]

  """
  def list_actions do
    Repo.all(Action)
  end

  @doc """
  Gets a single action.

  Raises `Ecto.NoResultsError` if the Action does not exist.

  ## Examples

      iex> get_action!(123)
      %Action{}

      iex> get_action!(456)
      ** (Ecto.NoResultsError)

  """
  def get_action!(id), do: Repo.get!(Action, id)

  def get_action_by_text(location, text) do
    embedding = Questify.Embeddings.embed!(text)
    min_distance = 0.5
    quest_id = location.quest_id

    IO.puts("\n=== Action Similarity Search ===")
    IO.puts("User input: #{text}")
    IO.puts("Location: #{location.name}")
    IO.puts("Quest ID: #{quest_id}")

    # First get all actions with their distances
    all_actions =
      Repo.all(
        from a in Action,
          select: %{a | min_distance: cosine_distance(a.embedding, ^embedding)},
          where: a.from_id == ^location.id or is_nil(a.from_id),
          where: a.quest_id == ^quest_id,
          order_by: cosine_distance(a.embedding, ^embedding)
      )

    # Log all actions and their distances
    IO.puts("\nAll available actions and their cosine distances:")
    Enum.each(all_actions, fn action ->
      IO.puts("Command: #{action.command}")
      IO.puts("Distance: #{Float.round(action.min_distance, 4)}")
      IO.puts("Available from: #{if action.from_id, do: "this location only", else: "anywhere"}")
      IO.puts("---")
    end)

    # Filter for chosen actions
    chosen = Enum.filter(all_actions, & &1.min_distance < min_distance)

    IO.puts("\nChosen actions (distance < #{min_distance}):")
    if Enum.empty?(chosen) do
      IO.puts("No actions found within minimum distance threshold")
    else
      Enum.each(chosen, fn action ->
        IO.puts("Selected: #{action.command} (distance: #{Float.round(action.min_distance, 4)})")
      end)
    end
    IO.puts("================================\n")

    chosen
  end

  @doc """
  Creates a action.

  ## Examples

      iex> create_action(%{field: value})
      {:ok, %Action{}}

      iex> create_action(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_action(attrs \\ %{}) do
    embedding = Questify.Embeddings.embed!(attrs["command"])
    attrs = Map.put(attrs, "embedding", embedding)

    %Action{}
    |> Action.changeset(attrs)
    |> Repo.insert()
  end

  def create_lore_action(quest) do
    trigger = "Tell me more about a specific rumor or location."
    description = "Replace with lore"

    create_action(%{
      "command" => trigger,
      "description" => description,
      "quest_id" => quest.id
    })
  end

  def create_trailblaze_action(quest) do
    triggers = [
      "Create a path to a location.",
      "Move to a location.",
      "Go to a location."
    ]
    description = "Replace with action"

    Enum.each(triggers, fn trigger ->
      create_action(%{
        "command" => trigger,
        "description" => description,
        "quest_id" => quest.id
      })
    end)
  end

  @doc """
  Updates a action.

  ## Examples

      iex> update_action(action, %{field: new_value})
      {:ok, %Action{}}

      iex> update_action(action, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_action(%Action{} = action, attrs) do
    action
    |> Action.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a action.

  ## Examples

      iex> delete_action(action)
      {:ok, %Action{}}

      iex> delete_action(action)
      {:error, %Ecto.Changeset{}}

  """
  def delete_action(%Action{} = action) do
    Repo.delete(action)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking action changes.

  ## Examples

      iex> change_action(action)
      %Ecto.Changeset{data: %Action{}}

  """
  def change_action(%Action{} = action, attrs \\ %{}) do
    Action.changeset(action, attrs)
  end

  alias Questify.Games.Play

  @doc """
  Returns the list of plays.

  ## Examples

      iex> list_plays()
      [%Play{}, ...]

  """
  def list_plays do
    Repo.all(Play)
  end

  @doc """
  Gets a single play.

  Raises `Ecto.NoResultsError` if the Play does not exist.

  ## Examples

      iex> get_play!(123)
      %Play{}

      iex> get_play!(456)
      ** (Ecto.NoResultsError)

  """
  def get_play!(id), do: Repo.get!(Play, id) |> Repo.preload([:quest, :location])

  @doc """
  Creates a play.

  ## Examples

      iex> create_play(%{field: value})
      {:ok, %Play{}}

      iex> create_play(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_play(attrs \\ %{}) do
    %Play{}
    |> Play.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a play.

  ## Examples

      iex> update_play(play, %{field: new_value})
      {:ok, %Play{}}

      iex> update_play(play, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_play(%Play{} = play, attrs) do
    play
    |> Play.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a play.

  ## Examples

      iex> delete_play(play)
      {:ok, %Play{}}

      iex> delete_play(play)
      {:error, %Ecto.Changeset{}}

  """
  def delete_play(%Play{} = play) do
    Repo.delete(play)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking play changes.

  ## Examples

      iex> change_play(play)
      %Ecto.Changeset{data: %Play{}}

  """
  def change_play(%Play{} = play, attrs \\ %{}) do
    Play.changeset(play, attrs)
  end

  def preload_quest_locations(quest) do
    Questify.Repo.preload(quest, :locations)
  end
end
