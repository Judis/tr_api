defmodule I18NAPI.Translations.StatisticsWatcher do
  @moduledoc """
  Initialize watcher for periodically recalculating statistics
  """
  use GenServer

  ## Public interface

  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: :statistics_watcher)

  def add(message), do: GenServer.cast(:statistics_watcher, {:add, message})
  #
  @impl true
  def handle_cast({:add, new_id}, state), do: {:noreply, MapSet.put(state, new_id)}

  def get(), do: GenServer.call(:statistics_watcher, :get)

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, MapSet.new}

  def get_periodically() do
    GenServer.info(:statistics_watcher, :get_periodically)
  end

  # Server
  def init(state) do
    schedule_get()
    {:ok, state}
  end

  defp schedule_get() do
    Process.send_after(self(), :work, 10)
  end

  @impl true
  def handle_info(:work, state) do
    spawn_link(__MODULE__, :do_work, [state])
    schedule_get()
    {:noreply, state}
  end

  def do_work(state) do
     IO.inspect state
  end
end
