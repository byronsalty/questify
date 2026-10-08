defmodule Questify.EmbeddingsTest do
  use ExUnit.Case, async: true

  alias Questify.Embeddings

  test "test env uses the stub adapter" do
    assert Application.get_env(:questify, :embeddings_adapter) == Questify.Embeddings.Stub
  end

  test "embed/2 returns a 1536-dimension vector without the network" do
    assert {:ok, %{text: "a dark cave", embedding: embedding}} = Embeddings.embed("a dark cave")
    assert length(embedding) == 1536
    assert Enum.all?(embedding, &is_float/1)
  end

  test "embed!/1 is deterministic per text" do
    assert Embeddings.embed!("a dark cave") == Embeddings.embed!("a dark cave")
    refute Embeddings.embed!("a dark cave") == Embeddings.embed!("a sunny meadow")
  end
end
