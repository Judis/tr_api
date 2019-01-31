defmodule I18NAPI.Composers do
  @callback compose(String.t(), Atom.t()) :: {:ok, term} | {:error, :invalid_data} | {:error, :nil_found}
  @callback extensions() :: String.t()
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
  def compose(keywords_list, ext) do
    ext
    |> get_module()
    |> call_composer(keywords_list, ext)
  end

  defp call_composer([], keywords_list, ext), do: {:error, :composer_not_defined}

  defp call_composer([module], keywords_list, ext) do
    module
    |> Kernel.apply(:compose, [keywords_list, ext])
  end
  
  defp get_module(ext) do
    with {:ok, raw_list} <- :application.get_key(:api, :modules) do
      raw_list
      |> Enum.filter(&valid_module_name?(&1))
      |> Enum.filter(&(Kernel.apply(&1, :extensions, []) |> Enum.member?(ext)))
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
