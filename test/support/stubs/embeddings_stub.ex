defmodule Questify.Embeddings.Stub do
  @moduledoc """
  Test embeddings adapter. Returns a deterministic 1536-dimension vector
  derived from the input text without touching the network.
  """

  @behaviour Questify.Embeddings

  @dimensions 1536

  @impl true
  def embed(text, _opts \\ []) when is_binary(text) do
    embedding = for i <- 1..@dimensions, do: :erlang.phash2({text, i}, 1_000_000) / 1_000_000

    {:ok, %{text: text, embedding: embedding}}
  end
end
