defmodule I18NAPI.Parsers.JSON do
  @behaviour I18NAPI.Parsers

  alias I18NAPI.Utilities

  @doc """
  Return file extensions, valid for this MIME type
  """
  @impl I18NAPI.Parsers
  def extensions(), do: ["json"]

  @impl I18NAPI.Parsers
  def parse(content) when is_nil(content), do: {:error, :nil_found}

  @impl I18NAPI.Parsers
  def parse(str) do
    with {:ok, map} <- Poison.decode(str) do
      {:ok, map |> flatten_key() |> Utilities.value_to_string()}
    else
      {:error, {:invalid, symbol, position}} ->
        {:error,
         %{errors: [invalid_json_with_symbol: symbol, invalid_json_in_position: position]}}

      {:error, :invalid, position} ->
        {:error, %{errors: [invalid_json_in_position: position]}}
    end
  end

  @doc """
  Flatten given map with nested key.

  All keys must be binary.
  Returns map

  ## Examples
      iex> flatten_key(%{"a" => "1", "b" => %{"ba" => "21", "bb" => %{"bba" => "241"}}, "c" => "3"})
      %{"a" => "1", "c" => "3", "b.ba" => "21", "b.bb.bba" => "241"}

  """
  @spec flatten_key(map) :: map
  def flatten_key(map) when is_map(map) do
    map
    |> Map.to_list()
    |> to_flat_map(%{})
  end

  defp to_flat_map([{pk, %{} = value} | t], acc) do
    value
    |> to_list(pk)
    |> to_flat_map(to_flat_map(t, acc))
  end

  defp to_flat_map([{k, v} | t], acc), do: to_flat_map(t, Map.put_new(acc, k, v))
  defp to_flat_map([], acc), do: acc
  defp to_list(map, pk) when is_binary(pk), do: Enum.map(map, &update_key(pk, &1))
  defp update_key(pk, {k, v} = _val) when is_binary(k), do: {"#{pk}.#{k}", v}
end
