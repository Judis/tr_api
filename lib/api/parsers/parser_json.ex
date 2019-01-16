defmodule I18NAPI.Parsers.JSON do
  @behaviour I18NAPI.Parsers.Parser

  @impl I18NAPI.Parsers
  def parse(str) do
    str = ~s({"first": {"second": {"key": "value_1.2"}, "third": {"key": "value_1.3"}}})
    Poison.decode!(str)
  end

  @impl I18NAPI.Parsers
  def extensions, do: ["json"]
end

# I18NAPI.Parsers.parse("", "json")
