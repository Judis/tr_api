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
        {key, value}, acc -> Map.put(acc, key |> to_string() |> String.to_existing_atom(), value)
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

  @doc """
  Translate values to strings

  ## Examples

      iex> value_to_string(%{field_a: 123, "field_b" => true})
      %{field_a: => "123", field_b: => "true"}
  """
  def value_to_string(map) do
    Enum.reduce(
      map,
      %{},
      fn
        {key, value}, acc when is_binary(value) -> Map.put(acc, key, value)
        {key, value}, acc -> Map.put(acc, key, to_string(value))
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
end
