defmodule I18NAPI.Parsers.YAML do
  @behaviour I18NAPI.Parsers.Parser

  @impl I18NAPI.Parsers
  # ... parse JSON
  def parse(str), do: {:ok, "some yaml " <> str}

  @impl I18NAPI.Parsers
  def extensions, do: ["yml", "yaml"]
end
