defmodule I18NAPI.ParserTest do
  use ExUnit.Case, async: true
  @moduletag :parser_api

  use I18NAPI.DataCase
  alias I18NAPI.Parsers
  @content_valid ~s({"a": 1})

  describe "content" do
    @content_empty ~s({})
    @content_invalid ~s({a: 1}})

    test "valid" do
      assert Parsers.parse(@content_valid, "json")
    end

    test "empty" do
      assert Parsers.parse(@content_empty, "json")
    end

    test "nil" do
      assert Parsers.parse(nil, "json")
    end
  end

  describe "extensions" do
    @ext_valid_lcase "json"
    @ext_valid_ucase "JSON"
    @ext_invalid "abrakadabra"

    test "valid lower case" do
      assert Parsers.parse(@content_valid, @ext_valid_lcase)
    end

    test "valid upper case" do
      assert Parsers.parse(@content_valid, @ext_valid_ucase)
    end

    test "invalid" do
      assert {:error, :parser_not_defined} == Parsers.parse(@content_valid, @ext_invalid)
    end

    test "nil" do
      assert {:error, :parser_not_defined} == Parsers.parse(@content_valid, nil)
    end
  end
end
