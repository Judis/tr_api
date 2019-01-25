defmodule I18NAPI.UtilitiesTest do
  use ExUnit.Case, async: true
  @moduletag :utilities_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup]

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

  describe "flatten_key" do
    @nested_valid %{a: 1, b: %{ba: 21, bb: %{bba: 241}}, c: 3}
    @flatten_valid %{"a" => 1, "c" => 3, "b.ba" => 21, "b.bb.bba" => 241}

    test "nested to flatten valid" do
     assert @flatten_valid == Utilities.flatten_key(@nested_valid)
    end

    test "flatten to flatten valid" do
      assert @flatten_valid == Utilities.flatten_key(@flatten_valid)
    end
  end
end
