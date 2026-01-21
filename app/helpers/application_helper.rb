# app/helpers/application_helper.rb
module ApplicationHelper
  def active_class(path)
    request.path.start_with?(path) ? "bg-gray-100 dark:bg-gray-700" : ""
  end

  def open_dropdown?(paths)
    paths.any? { |p| request.path.start_with?(p) }
  end
  def safe_avatar(user, size: 38)
    if user&.thumbnail&.attached? &&
       user.thumbnail.blob&.persisted?

      image_tag(
        user.thumbnail.variant(resize_to_fill: [size, size]),
        class: "rounded-full object-cover",
        width: size,
        height: size
      )
    else
      image_tag(
        default_avatar,
        class: "rounded-full object-cover",
        width: size,
        height: size
      )
    end
  rescue ActiveStorage::FileNotFoundError
    image_tag(
      default_avatar,
      class: "rounded-full object-cover",
      width: size,
      height: size
    )
  end

  def default_avatar
    "https://flowbite.com/docs/images/people/profile-picture-5.jpg"
  end
end
