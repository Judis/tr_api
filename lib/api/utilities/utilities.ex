defmodule I18NAPI.Utilities do
  @moduledoc false

  @doc """
  Translate keys to atoms

  ## Examples

      iex> key_to_atom(%{field_a: value, "field_b" => "value"})
      %{field_a: value, field_b: "value"}
  """
  def key_to_atom(map) do
    Enum.reduce(
      map,
      %{},
      fn
        {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
        # String.to_existing_atom saves us from overloading the VM by
        # creating too many atoms. It'll always succeed because all the fields
        # in the database already exist as atoms at runtime.
        {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
      end
    )
  end

  @doc """
  Translate keys to strings

  ## Examples

      iex> key_to_string(%{field_a: value, "field_b" => "value"})
      %{"field_a" => value, "field_b" => "value"}
  """
  def key_to_string(map) do
    Enum.reduce(
      map,
      %{},
      fn
        {key, value}, acc when is_binary(key) -> Map.put(acc, key, value)
        {key, value}, acc when is_atom(key) -> Map.put(acc, Atom.to_string(key), value)
      end
    )
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def generate_valid_password do
    random_string(32)
  end

  @doc """
  Validates that one or more fields are present in the changeset.

  If the value of a field is `nil` or a string made only of whitespace,
  the changeset is marked as invalid and an error is added. Note the
  error won't be added though if the field already has an error.

  You can pass a single field name or a list of field names that
  are required.

  ## Examples

      validate_required(map, :title)
      validate_required(map, [:title, :body])

  """
  def validate_required(%{} = input_map, fields) do
    map = key_to_atom(input_map)

    fields_with_errors =
      for field <- List.wrap(fields),
          not Map.has_key?(map, field) or is_nil(Map.get(map, field)),
          do: field

    case fields_with_errors do
      [] -> {:ok, input_map}
      _ -> {:error, :bad_request, Enum.map(fields_with_errors, &%{&1 => "can't be blank"})}
    end
  end

  @doc """
    Returns the current datetime in UTC.
  """
  def get_utc_now(), do: NaiveDateTime.utc_now()

  @doc """
  Flatten given map with nested key.

  All keys must be atom or binary.
  Returns map

  ## Examples
      iex> flatten_with_parent_key(%{a: 1, b: %{ba: 21, bb: %{bba: 241}}, c: 3})
      %{:a => 1, :c => 3, "b.ba" => 21, "b.bb.bba" => 241}

  """
  @spec flatten_key(map) :: map
  def flatten_key(map) when is_map(map) do
    map
    |> Map.to_list()
    |> to_flat_map(%{})
    |> key_to_string()
  end

  defp to_flat_map([{pk, %{} = v} | t], acc) do
    v |> to_list(pk) |> to_flat_map(to_flat_map(t, acc))
  end

  defp to_flat_map([{k, v} | t], acc), do: to_flat_map(t, Map.put_new(acc, k, v))
  defp to_flat_map([], acc), do: acc

  defp to_list(map, pk) when is_atom(pk), do: to_list(map, Atom.to_string(pk))
  defp to_list(map, pk) when is_binary(pk), do: Enum.map(map, &update_key(pk, &1))

  defp update_key(pk, {k, v} = _val) when is_atom(k), do: update_key(pk, {Atom.to_string(k), v})
  defp update_key(pk, {k, v} = _val) when is_binary(k), do: {"#{pk}.#{k}", v}
end
