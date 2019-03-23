defmodule I18NAPI.ComposerJsonTest do
  use ExUnit.Case, async: true
  @moduletag :composer_json_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup]
  alias I18NAPI.Composers.JSON

  @formats [:json, :json_flat, :json_nested]
  @json_valid_nested ~s({"a":{"b":{"c":"c"}}})
  @json_valid_flat ~s({"a.b.c":"c"})
  @map_valid %{"a.b.c" => "c"}

  describe "parse JSON" do
    test "valid nested" do
      assert {:ok, @json_valid_nested} = JSON.compose(@map_valid, :json_nested)
    end

    test "valid simple named nested" do
      assert {:ok, @json_valid_nested} = JSON.compose(@map_valid, :json)
    end

    test "valid flat" do
      assert {:ok, @json_valid_flat} = JSON.compose(@map_valid, :json_flat)
    end

    test "nil" do
      assert {:error, :nil_found} = JSON.compose(nil, :json)
    end
  end

  describe "JSON formats" do
    test "get valid" do
      assert @formats == JSON.formats()
    end
  end

  describe "JSON extention" do
    test "get valid" do
      assert "json" == JSON.extension()
    end
  end
end
