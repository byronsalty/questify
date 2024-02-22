defmodule Questify.GenerationHandler do
  use GenServer

  alias ExAws.S3

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_generating(filename, prompt) do
    # create a post request to the server
    GenServer.cast(__MODULE__, {:generate, filename, prompt})
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_cast({:generate, file_name, prompt}, _state) do
    openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]
    endpoint = Application.get_env(:questify, :openai)[:image_gen_url]

    {model, size} = {"dall-e-3", "1024x1024"}

    data =
      %{
        "model" => model,
        "size" => size,
        "quality" => "standard",
        "n" => 1,
        "prompt" => prompt
      }
      |> Jason.encode!()

    opts = [async: true, recv_timeout: 30_000, timeout: 30_000]

    response =
      HTTPoison.post!(
        endpoint,
        data,
        [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{openai_api_key}"}
        ],
        opts
      )

    response_body =
      response
      |> Map.get(:body)
      |> Jason.decode!()

    image_url = response_body |> get_in(["data", Access.at(0), "url"])



    {:ok, file_response} = HTTPoison.get(image_url)


    write_file_to_s3(file_name, file_response.body, "image/png")
    |> IO.inspect(label: "write_file_to_s3")

    # TODO: broadcast that file is ready on s3

    {:noreply, nil}
  end

  def create_img_url(hash) do
    file_name = "#{hash}.png"
    url = "https://d8g32g7q3zoxw.cloudfront.net/#{file_name}"

    {url, file_name}
  end

  def test_gen() do
    echo = Questify.Games.get_quest_by_slug!("echo")

    Questify.Games.create_location(%{
      "name" => "Echo Ridge Tavern",
      "description" => """
      You arrive at the Echo Ridge Tavern. People sit in the dark shadows drinking alone or watch others as they gamble with dice. Alcohol flows readily, as do tips for the beer maidens.
      """,
      "is_terminal" => false,
      "is_starting" => false,
      "quest_id" => echo.id
    })
  end

  defp write_file_to_s3(unique_path, file_binary, content_type) do
    bucket_name = "quest-publish"

    IO.inspect("Writing file to S3: #{unique_path}")

    doc =
      S3.put_object(
        bucket_name,
        unique_path,
        file_binary,
        content_type: content_type
      )
      |> ExAws.request()

    {doc, bucket_name}
  end
end
