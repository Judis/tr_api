defmodule I18NAPI.Composers do
  @callback compose(String.t(), Atom.t()) :: {:ok, term} | {:error, :invalid_data} | {:error, :nil_found}
  @callback formats() :: String.t()
  @callback extension() :: String.t()
  alias I18NAPI.Utilities

  @doc """
    Compose keywords list to file with concrete extension

      ## Examples

          iex> compose([{"key", "value"}], :json)
          response

          iex> compose([{"key", "value"}], :abrakadabra)
          {:error, :parser_not_defined}
  """
  def compose(keywords_list, _) when is_nil(keywords_list), do: {:error, :nil_found}
  def compose(keywords_list, format) do
    with [module] <- get_module(format),
    {:ok, data} <- call_composer([module], keywords_list, format) do
      {:ok, data, call_extension([module])}
    end
  end

  defp call_composer([], keywords_list, format), do: {:error, :composer_not_defined}

  defp call_composer([module], keywords_list, format) do
    module
    |> Kernel.apply(:compose, [keywords_list, format])
  end

  defp call_extension([]), do: {:error, :composer_not_defined}
  defp call_extension([module]) do
    module
    |> Kernel.apply(:extension, [])
  end

  def get_module(ext) do
    with {:ok, raw_list} <- :application.get_key(:api, :modules) do
      raw_list
      |> Enum.filter(&valid_module_name?(&1))
      |> Enum.filter(&(Kernel.apply(&1, :formats, []) |> Enum.member?(ext)))
    end
  end

  @included_module_prefix "Elixir.I18NAPI.Composers"
  @excluded_modules ["Elixir.I18NAPI.Composers"]

  defp valid_module_name?(name) do
    name = to_string(name)

    if Enum.member?(@excluded_modules, name) do
      false
    else
      String.starts_with?(name, @included_module_prefix)
    end
  end
end
