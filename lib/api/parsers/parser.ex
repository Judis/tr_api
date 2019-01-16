defmodule I18NAPI.Parsers do
  @callback parse(String.t()) :: {:ok, term} | {:error, String.t()}
  @callback extensions() :: [String.t()]
  alias I18NAPI.Utilities

  def parse(content, ext) do
    call_parser(get_module(ext), content)
  end

  defp call_parser([], content), do: {:error, :parser_not_defined}

  defp call_parser([module], content) do
    Kernel.apply(module, :parse, [content])
    |> Utilities.flatten_with_parent_key()
  end

  defp get_module(ext) do
    with {:ok, raw_list} <- :application.get_key(:api, :modules) do
      raw_list
      |> Enum.filter(
        &(String.starts_with?(to_string(&1), "Elixir.I18NAPI.Parsers") and
            not String.equivalent?(to_string(&1), "Elixir.I18NAPI.Parsers"))
      )
      |> Enum.filter(&(Kernel.apply(&1, :extensions, []) |> Enum.member?(ext)))
    end
  end
end
