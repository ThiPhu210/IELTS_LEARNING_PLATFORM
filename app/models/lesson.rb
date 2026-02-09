class Lesson < ApplicationRecord
  belongs_to :course_section

  has_one_attached  :video
  has_many_attached :pdfs
  has_many :speaking_topics, dependent: :destroy
  accepts_nested_attributes_for :speaking_topics, allow_destroy: true

  validates :title,
            length: { maximum: 255 }

  validates :duration,
            numericality: { greater_than: 0 },
            allow_nil: true

  # ✅ chỉ validate khi CÓ FILE
  validate :video_type, if: -> { video.attached? }
  validate :video_size, if: -> { video.attached? }
  validate :pdfs_type,  if: -> { pdfs.attached? }
  validate :pdfs_size,  if: -> { pdfs.attached? }

  def video_thumbnail
    return unless video.attached?

    video.preview(
      resize_to_limit: [ 640, 360 ],
      format: "jpg"
    )
  end

  def video_type
    errors.add(:video, "chỉ cho phép MP4") unless video.content_type == "video/mp4"
  end

  def video_size
    errors.add(:video, "tối đa 5MB") if video.byte_size > 5.megabytes
  end

  def pdfs_type
    pdfs.each do |pdf|
      errors.add(:pdfs, "chỉ cho phép file PDF") unless pdf.content_type == "application/pdf"
    end
  end

  def pdfs_size
    pdfs.each do |pdf|
      errors.add(:pdfs, "mỗi file tối đa 500KB") if pdf.byte_size > 500.kilobytes
    end
  end
end
