defmodule I18NAPI.Parsers.YAML do
  @behaviour I18NAPI.Parsers

  @doc """
  Return file extensions, valid for this MIME type
  """
  @impl I18NAPI.Parsers
  def extensions(), do: ["yaml"]

  @impl I18NAPI.Parsers
  def parse(content) when is_nil(content), do: {:error, :nil_found}

  @impl I18NAPI.Parsers
  def parse(str) do
    :yamerl.decode(str)
    |> flatten_key()
  end

  @doc """
  Flatten given keywords list with nested key.

  All keys must be binary or char list.
  Returns flat map

  ## Examples
      iex> flatten_key([{"a" => {'b' => 'b', "c" => "c"}}])
      %{"a.b" => "b", "a.c" => "c"}

  """
  @spec flatten_key(list) :: list

  def flatten_key(list) when is_list(list) do
    list
    |> to_flat_list(%{})
  end

  defp to_flat_list([{pk, {} = value} | t], acc) do
    value
    |> Keyword.to_list()
    |> to_flat_list(to_flat_list(t, acc))
  end

  defp to_flat_list({key, [{inner_k, inner_v} | []]}, acc) do
    [{"#{key}.#{inner_k}", inner_v}]
    |> to_flat_list(acc)
  end

  defp to_flat_list({key, [{inner_k, inner_v} | t]}, acc) do
    [{"#{key}.#{inner_k}", inner_v}, {key, t}]
    |> to_flat_list(acc)
  end

  defp to_flat_list([h | []], acc), do: to_flat_list(h, acc)
  defp to_flat_list([h | t], acc), do: h |> to_flat_list(t |> to_flat_list(acc))

  defp to_flat_list({key, value}, acc),
    do: to_flat_list([], acc |> Map.put(to_string(key), to_string(value)))

  defp to_flat_list([], acc), do: acc
end
