module AvatarHelper
    def avatar_for(profile, size: 40)
      if profile&.avatar&.attached?
        image_tag profile.avatar.variant(
                    resize_to_fill: [size, size]
                  ),
                  width: size,
                  height: size,
                  class: "rounded-full object-cover"
      else
        content_tag :div,
          "",
          class: "rounded-full bg-gray-300 flex items-center justify-center",
          style: "width: #{size}px; height: #{size}px"
      end
    end
  end
  