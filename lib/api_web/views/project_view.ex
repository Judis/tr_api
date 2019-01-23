defmodule I18NAPIWeb.ProjectView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.ProjectView

  def render("index.json", %{projects: projects}) do
    %{data: render_many(projects, ProjectView, "project.json")}
  end

  def render("show.json", %{project: project}) do
    %{data: render_one(project, ProjectView, "project.json")}
  end

  def render("project.json", %{project: project}) do
    %{
      id: project.id,
      name: project.name,
      total_count_of_translation_keys: project.total_count_of_translation_keys,
      count_of_not_verified_keys: project.count_of_not_verified_keys,
      count_of_verified_keys: project.count_of_verified_keys,
      count_of_translated_keys: project.count_of_translated_keys,
      count_of_untranslated_keys: project.count_of_untranslated_keys,
      is_removed: project.is_removed,
      removed_at: project.removed_at
    }
  end
end
