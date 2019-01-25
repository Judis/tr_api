defmodule I18NAPI.Parsers do
  @callback parse(String.t()) :: {:ok, term} | {:error, :invalid_data} | {:error, :nil_found}
  @callback extensions() :: [String.t()]
  alias I18NAPI.Utilities

  @doc """
    Parse content of file with concrete extension

      ## Examples

          iex> parse(~s({"first": {"second": {"key": "value_1.2"}}}), "json")
          response

          iex> parse(~s(key, value), "abrakadabra")
          {:error, :parser_not_defined}
  """
  def parse(content, _) when is_nil(content), do: {:error, :nil_found}

  def parse(content, ext) do
    ext
    |> get_module()
    |> call_parser(content)
  end

  defp call_parser([], content), do: {:error, :parser_not_defined}

  defp call_parser([module], content) do
    module
    |> Kernel.apply(:parse, [content])
  end

  defp get_module(ext) do
    with {:ok, raw_list} <- :application.get_key(:api, :modules) do
      raw_list
      |> Enum.filter(&valid_module_name?(&1))
      |> Enum.filter(&(Kernel.apply(&1, :extensions, []) |> Enum.member?(ext)))
    end
  end

  @included_module_prefix "Elixir.I18NAPI.Parsers"
  @excluded_modules ["Elixir.I18NAPI.Parsers"]

  defp valid_module_name?(name) do
    name = to_string(name)

    with String.starts_with?(name, @included_module_prefix) do
      List.keymember?(@excluded_modules, name, 0)
    end
  end
end
