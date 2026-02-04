# app/helpers/application_helper.rb
module ApplicationHelper
  def active_class(path)
    request.path.start_with?(path) ? "bg-gray-100 dark:bg-gray-700" : ""
  end

  def open_dropdown?(paths)
    paths.any? { |p| request.path.start_with?(p) }
  end
  def safe_avatar(user, size: 64)
    return default_avatar(size) unless user.thumbnail.attached?

    attachment = user.thumbnail

    if attachment.content_type == "image/svg+xml"
      image_tag attachment,
                class: "rounded-full",
                width: size,
                height: size,
                alt: "user avatar"
    else
      image_tag attachment.variant(resize_to_fill: [ size, size ]),
                class: "rounded-full",
                alt: "user avatar"
    end
  end

  def default_avatar(size)
    image_tag "https://flowbite.com/docs/images/people/profile-picture-5.jpg",
              class: "rounded-full",
              width: size,
              height: size,
              alt: "default avatar"
  end
end
