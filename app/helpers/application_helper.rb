module ApplicationHelper
  def nav_link_to(name, path)
    classes = "px-3"
    classes << " font-semibold underline underline-offset-8" if current_page?(path)
    link_to name, path, class: classes
  end
end
