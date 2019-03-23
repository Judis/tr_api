defmodule I18NAPI.ParserYamlTest do
  use ExUnit.Case, async: true
  @moduletag :parser_yaml_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup]
  alias I18NAPI.Parsers.YAML

  @extensions ["yaml"]
  @yaml_valid_level_1 ~s([{a: a}])
  @map_valid_level_1 %{"a" => "a"}
  @yaml_valid_level_2 ~s([{a: {b: b}}])
  @map_valid_level_2 %{"a.b" => "b"}
  @yaml_valid_level_3 ~s([{a: {b: {c: c}}}])
  @map_valid_level_3 %{"a.b.c" => "c"}

  @yaml_valid_level_3_3_2_1_2 ~s([{a: {b: {c: c, d: d}, e: e}, f: f}, {a: {g: g}}])
  @map_valid_level_3_3_2_1_2 %{"a.b.c" => "c", "a.b.d" => "d", "a.e" => "e", "f" => "f", "a.g" => "g"}

  describe "parse YAML" do
    test "valid nested level 1" do
      assert @map_valid_level_1 == YAML.parse(@yaml_valid_level_1)
    end

    test "valid nested level 2" do
      assert @map_valid_level_2 == YAML.parse(@yaml_valid_level_2)
    end

    test "valid nested level 3" do
      assert @map_valid_level_3 == YAML.parse(@yaml_valid_level_3)
    end

    test "valid nested level 3_3" do
      assert @map_valid_level_3_3_2_1_2 == YAML.parse(@yaml_valid_level_3_3_2_1_2)
    end
  end

  describe "YAML extensions" do
    test "get valid" do
      assert @extensions == YAML.extensions()
    end
  end
end
