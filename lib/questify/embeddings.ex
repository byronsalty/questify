defmodule Questify.Embeddings do
  @moduledoc """
  Generates vector embeddings for text.

  Calls are delegated to the adapter configured under
  `config :questify, :embeddings_adapter`, defaulting to
  `Questify.Embeddings.OpenAI`. The test env swaps in a stub so the
  suite never hits the network.
  """

  @callback embed(text :: String.t(), opts :: Keyword.t()) ::
              {:ok, %{text: String.t(), embedding: [float()]}} | {:error, term()}

  def embed(text, opts \\ []) when is_binary(text) do
    adapter().embed(text, opts)
  end

  def embed!(text, opts \\ []) when is_binary(text) do
    {:ok, %{embedding: embedding}} = embed(text, opts)
    embedding
  end

  defp adapter do
    Application.get_env(:questify, :embeddings_adapter, Questify.Embeddings.OpenAI)
  end
end
