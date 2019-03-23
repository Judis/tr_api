defmodule I18NAPI.ComposerTest do
  use ExUnit.Case, async: true
  @moduletag :composer_api

  use I18NAPI.DataCase
  alias I18NAPI.Composers
  @content_valid %{a: 1}

  describe "content" do
    test "valid" do
      assert {:ok, "{\"a\":1}", "json"} = Composers.compose(@content_valid, :json_flat)
    end

    test "nil" do
      assert {:error, :nil_found} == Composers.compose(nil, :json_flat)
    end
  end

  describe "extensions" do
    @ext_valid_flat :json_flat
    @ext_invalid "abrakadabra"

    test "valid" do
      assert {:ok, _, "json"} = Composers.compose(@content_valid, @ext_valid_flat)
    end

    test "invalid" do
      assert {:error, :composer_not_defined} = Composers.compose(@content_valid, @ext_invalid)
    end

    test "nil" do
      assert {:error, :composer_not_defined} = Composers.compose(@content_valid, nil)
    end
  end
end
