defmodule I18NAPI.Translations.StatisticsSupervisor do
  @moduledoc """
  Initialize different observers for different entities
  """
  use Supervisor
  alias I18NAPI.Translations.StatisticsWatcher

  def start_link() do
    children = [
      %{
        id: StatisticsWatcher,
        start: {StatisticsWatcher, :start_link, [{MapSet.new(), MapSet.new()}]}
      }
    ]

    Supervisor.start_link(__MODULE__, children)
  end

  def init(state), do: Supervisor.init(state, strategy: :one_for_one)
end
