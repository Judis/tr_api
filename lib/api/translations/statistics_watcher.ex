defmodule I18NAPI.Translations.StatisticsWatcherInterface do
  @moduledoc """
  Interface for I18NAPI.Translations.StatisticsWatcher
  """
  alias I18NAPI.Translations.StatisticsWatcher

  def recalculate_locale_statistics(piped_data, locale_id, project_id \\ nil) do
    StatisticsWatcher.add_locale({locale_id, project_id})
    piped_data
  end

  def recalculate_project_statistics(piped_data, project_id) do
    StatisticsWatcher.add_project(project_id)
    piped_data
  end

  def recalculate_statistics_parent_project_by_locale_id(piped_data, locale_id) do
    StatisticsWatcher.add_parent_project_by_locale_id(locale_id)
    piped_data
  end

  def recalculate_statistics_all_child_locales_in_project(piped_data, project_id) do
    StatisticsWatcher.add_all_child_locales_in_project(project_id)
    piped_data
  end
end

defmodule I18NAPI.Translations.StatisticsWatcher do
  @moduledoc """
  Initialize watcher for periodically recalculating statistics
  """
  use GenServer
  alias I18NAPI.Translations
  alias I18NAPI.Translations.Statistics
  @name :statistics_watcher

  # Public interface

  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: @name)

  def add_locale({locale_id, project_id}),
    do: GenServer.cast(@name, {:add_locale, {locale_id, project_id}})

  def add_project(message), do: GenServer.cast(@name, {:add_project, message})

  def add_parent_project_by_locale_id(message),
    do: GenServer.cast(@name, {:add_parent_project_by_locale_id, message})

  def add_all_child_locales_in_project(message),
    do: GenServer.cast(@name, {:add_all_child_locales_in_project, message})

  def flush(), do: GenServer.call(@name, :flush)

  def get(), do: GenServer.call(@name, :get)

  # Implementation
  @impl true
  def handle_cast({:add_locale, {locale_id, project_id}}, {projects, locales}) do
    {:noreply, {projects, MapSet.put(locales, {locale_id, project_id})}}
  end

  @impl true
  def handle_cast({:add_project, new_id}, {projects, locales}),
    do: {:noreply, {MapSet.put(projects, new_id), locales}}

  @impl true
  def handle_cast({:add_parent_project_by_locale_id, locale_id}, {projects, locales}) do
    project_id = Translations.get_locale!(locale_id).project_id
    {:noreply, {MapSet.put(projects, project_id), locales}}
  end

  @impl true
  def handle_cast({:add_all_child_locales_in_project, project_id}, {projects, locales}) do
    result_locales =
      Translations.list_locale_identities(project_id)
      |> put_to_map_set_from_list(locales, project_id)

    {:noreply, {MapSet.put(projects, project_id), result_locales}}
  end

  @impl true
  def handle_call(:flush, _from, state), do: {:reply, state, {MapSet.new(), MapSet.new()}}

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info(:work, state) do
    process_statistics(state)
    schedule_processing()

    {:noreply, {MapSet.new(), MapSet.new()}}
  end

  # Server

  @impl true
  def init(state) do
    schedule_processing()
    {:ok, state}
  end

  defp schedule_processing() do
    unless Mix.env() == :test do
      Process.send_after(
        self(),
        :work,
        Application.get_env(:api, @name)[:statistic_recalculating_period]
      )
    end
  end

  def process_statistics({projects, locales}) do
    locales
    |> MapSet.to_list()
    |> List.flatten()
    |> recalculate_locales

    projects
    |> MapSet.to_list()
    |> List.flatten()
    |> recalculate_projects
  end

  defp recalculate_locales([]), do: []

  defp recalculate_locales([head | locales]) do
    {locale_id, project_id} = head

    task =
      Task.async(fn ->
        Statistics.update_all_locale_counts(locale_id, project_id)
      end)

    result_locales = recalculate_locales(locales)
    Task.await(task)
    result_locales
  end

  defp recalculate_projects([]), do: []

  defp recalculate_projects([head | projects]) do
    task =
      Task.async(fn ->
        Statistics.update_all_project_counts(head)
      end)

    result_projects = recalculate_projects(projects)
    Task.await(task)
    result_projects
  end

  defp put_to_map_set_from_list([], locales_map_set, _), do: locales_map_set

  defp put_to_map_set_from_list([list_head | list_tail], locales_map_set, project_id) do
    put_to_map_set_from_list(
      list_tail,
      MapSet.put(locales_map_set, {list_head, project_id}),
      project_id
    )
  end
end
