defmodule I18NAPI.ParserJsonTest do
  use ExUnit.Case, async: true
  @moduletag :parser_json_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup]
  alias I18NAPI.Parsers.JSON

  @extensions ["json"]
  @json_valid_nested ~s({"a": {"b": {"key": "value_1.2"}, "c": {"key": "value_1.3"}}})
  @json_valid_flat ~s({"a.b": {"key": "value_1.2"},"a.c": {"key": "value_1.3"}})
  @json_invalid ~s({"a.b": {"key": "value_1.2"},"a.c": {"key": "value_1.3"}}})
  @map_valid %{"a.b.key" => "value_1.2", "a.c.key" => "value_1.3"}

  describe "parse JSON" do
    test "valid nested" do
      assert {:ok, @map_valid} == JSON.parse(@json_valid_nested)
    end

    test "valid flat" do
      assert {:ok, @map_valid} == JSON.parse(@json_valid_flat)
    end

    test "invalid" do
      assert {:error, %{errors: _}} = JSON.parse(@json_invalid)
    end

    test "nil" do
      assert JSON.parse(nil)
    end
  end

  describe "JSON extensions" do
    test "get valid" do
      assert @extensions == JSON.extensions()
    end
  end
end
