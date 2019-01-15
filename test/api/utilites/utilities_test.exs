defmodule I18NAPI.UtilitiesTest do
  use ExUnit.Case, async: true
  @moduletag :utilities_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup]

  import Swoosh.TestAssertions

  alias I18NAPI.Utilities

  test "key_to_atom(map)" do
    :a
    map_with_string = %{"a" => 1, :b => 2, "c" => 3}
    assert %{a: 1, b: 2} = Utilities.key_to_atom(map_with_string)
  end

  test "key_to_string(map)" do
    map_with_atom = %{"a" => 1, :b => 2, "c" => 3}
    assert %{"a" => 1, "b" => 2, "c" => 3} = Utilities.key_to_string(map_with_atom)
  end

  test "random_string(length)" do
    const_a = 32
    const_b = 33
    const_c = 5
    assert const_a == Utilities.random_string(const_a) |> String.length
    assert const_b == Utilities.random_string(const_b) |> String.length
    assert const_c == Utilities.random_string(const_c) |> String.length

    refute Utilities.random_string(const_a) == Utilities.random_string(const_a)
    refute Utilities.random_string(const_b) == Utilities.random_string(const_b)
    refute Utilities.random_string(const_c) == Utilities.random_string(const_c)
  end

  test "generate_valid_password" do
    password = Utilities.generate_valid_password
    assert 32 == password |> String.length
  end
end
