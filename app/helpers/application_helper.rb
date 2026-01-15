# app/helpers/application_helper.rb
module ApplicationHelper
  def active_class(path)
    request.path.start_with?(path) ? "bg-gray-100 dark:bg-gray-700" : ""
  end

  def open_dropdown?(paths)
    paths.any? { |p| request.path.start_with?(p) }
  end
end
