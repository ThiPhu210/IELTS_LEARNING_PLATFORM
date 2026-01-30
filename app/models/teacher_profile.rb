class TeacherProfile < ApplicationRecord
  has_one_attached :avatar
  validates :expertise, presence: true
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }
  after_commit :compress_avatar, if: :avatar_attached_changed?
  private

  def avatar_attached_changed?
    avatar.attached? && avatar.blob&.new_record?
  end

  def compress_avatar
    downloaded = Tempfile.new([ "original", ".jpg" ])
    downloaded.binmode
    downloaded.write(avatar.download)
    downloaded.rewind

    compressed = ImageCompressor.compress(downloaded)

    avatar.detach
    avatar.attach(
      io: compressed,
      filename: "avatar.jpg",
      content_type: "image/jpeg"
    )
  end
end
