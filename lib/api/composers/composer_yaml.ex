defmodule I18NAPI.Composers.YAML do
  @behaviour I18NAPI.Composers

  @impl I18NAPI.Composers
  def formats(), do: [:yaml, :yaml_flat, :yaml_nested]
  @impl I18NAPI.Composers
  def extension(), do: "yaml"

  @impl I18NAPI.Composers
  def compose(keywords_list, _) when is_nil(keywords_list), do: {:error, :nil_found}

  @impl I18NAPI.Composers
  def compose(keywords_list, :yaml_flat) do
    keywords_list
    |> Enum.into(%{})
    |> YamlEncoder.encode()
  end

  @impl I18NAPI.Composers
  def compose(keywords_list, ext) when :yaml == ext or :yaml_nested == ext do
    keywords_list
    |> Enum.into(%{})
    |> to_nested_map()
    |> YamlEncoder.encode()
  end

  def to_nested_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, nested_map ->
      merge(nested_map, String.split(key, "."), value)
    end)
  end

  defp merge(map, [leaf], value), do: Map.put(map, leaf, value)

  defp merge(map, [node | remaining_keys], value) do
    inner_map = merge(Map.get(map, node, %{}), remaining_keys, value)
    Map.put(map, node, inner_map)
  end
end
