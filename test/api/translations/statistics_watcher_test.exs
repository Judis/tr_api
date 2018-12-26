defmodule I18NAPI.StatisticsWorkerTest do
  use ExUnit.Case, async: true
  @moduletag :statistics_worker_api

  use I18NAPI.DataCase
  alias I18NAPI.Translations.StatisticsWatcher

  setup do
    supervisor_pid = GenServer.whereis(:statistics_supervisor)
    {:ok, server: supervisor_pid}
  end

  describe "init" do
    test "start StatisticsSupervisor", %{server: pid} do
      assert pid == GenServer.whereis(:statistics_supervisor)
    end

    test "start StatisticsWatcher" do
      assert GenServer.whereis(:statistics_watcher)
    end

    test "observers test" do
     StatisticsWatcher.add(project: 1)
      StatisticsWatcher.add(project: 2)
      StatisticsWatcher.add(locale: 3)
      StatisticsWatcher.add(locale: 4)
      StatisticsWatcher.add(locale: 3)

      result_fixture =
        MapSet.new()
        |> MapSet.put(project: 1)
        |> MapSet.put(project: 2)
        |> MapSet.put(locale: 3)
        |> MapSet.put(locale: 4)

      assert MapSet.equal?(result_fixture, StatisticsWatcher.get())
    end
  end
end
