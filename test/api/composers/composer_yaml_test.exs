defmodule I18NAPI.ComposerYamlTest do
  use ExUnit.Case, async: true
  @moduletag :composer_yaml_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup]
  alias I18NAPI.Composers.YAML

  @formats [:yaml, :yaml_flat, :yaml_nested]
  @yaml_valid_nested "a:\n  b:\n    c: \"c\"\n    d: \"d\"\n  e: \"e\"\n  g: \"g\"\nf: \"f\"\n"

  @yaml_valid_flat "a.b.c: \"c\"\na.b.d: \"d\"\na.e: \"e\"\na.g: \"g\"\nf: \"f\"\n"

  @map_valid %{"a.b.c" => "c", "a.b.d" => "d", "a.e" => "e", "f" => "f", "a.g" => "g"}

  describe "parse YAML" do
    test "valid nested" do
      assert @yaml_valid_nested = YAML.compose(@map_valid, :yaml_nested)
    end

    test "valid flat" do
      assert @yaml_valid_flat = YAML.compose(@map_valid, :yaml_flat)
    end

    test "nil" do
      assert {:error, :nil_found} = YAML.compose(nil, :yaml)
    end
  end

  describe "YAML formats" do
    test "get valid" do
      assert @formats == YAML.formats()
    end
  end

  describe "YAML extention" do
    test "get valid" do
      assert "yaml" == YAML.extension()
    end
  end
end
