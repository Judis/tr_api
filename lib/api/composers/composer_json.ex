defmodule I18NAPI.Composers.JSON do
  @behaviour I18NAPI.Composers.Composer

  @doc """
  Return file extensions, valid for this MIME type
  """
  def extensions(), do: [:json, :json_flat, :json_nested]

  @impl I18NAPI.Composers
  def compose(keywords_list, _) when is_nil(keywords_list), do: {:error, :nil_found}

  @impl I18NAPI.Composers
  def compose(keywords_list, :json_flat) do
    keywords_list
    |> Enum.into(%{})
    |> Poison.encode()
  end

  @impl I18NAPI.Composers
  def compose(keywords_list, ext) when :json  == ext or :json_nested == ext do
    keywords_list
    |> Enum.into(%{})
    |> to_nested_map()
    |> Poison.encode()
  end

  def to_nested_map(keywords_list) do
    Enum.reduce(keywords_list, %{},
      fn({key, value}, nested_map) ->
        merge(nested_map, String.split(key, "."), value)
      end
    )
  end
  defp merge(map, [leaf], value), do: Map.put(map, leaf, value)
  defp merge(map, [node | remaining_keys], value) do
    inner_map = merge(Map.get(map, node, %{}), remaining_keys, value)
    Map.put(map, node, inner_map)
  end
end
