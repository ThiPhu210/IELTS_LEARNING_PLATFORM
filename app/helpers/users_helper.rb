module UsersHelper
  def user_avatar(user, size: 40)
    if user.thumbnail.attached?
      image_tag user.thumbnail.variant(resize_to_fill: [size, size]),
        class: "w-#{size} h-#{size} rounded-full object-cover"
    else
      content_tag :div,
        user.full_name.first.upcase,
        class: "w-#{size} h-#{size} rounded-full bg-gray-400 flex items-center justify-center text-white font-bold"
    end
  end
end
