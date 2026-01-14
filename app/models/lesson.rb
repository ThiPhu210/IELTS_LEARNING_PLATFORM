class Lesson < ApplicationRecord
  belongs_to :course_section

  has_one_attached  :video
  has_many_attached :pdfs

  validates :title,
            presence: true,
            length: { maximum: 255 }

  validates :duration,
            numericality: { greater_than: 0 },
            allow_nil: true

  validate :video_presence
  validate :video_type
  validate :video_size
  validate :pdfs_type
  validate :pdfs_size
  def video_presence
    errors.add(:video, "phải được upload") unless video.attached?
  end

  def video_type
    return unless video.attached?

    unless video.content_type == "video/mp4"
      errors.add(:video, "chỉ cho phép MP4")
    end
  end

  def video_size
    return unless video.attached?

    if video.byte_size > 500.megabytes
      errors.add(:video, "tối đa 500MB")
    end
  end

  def pdfs_type
    pdfs.each do |pdf|
      unless pdf.content_type == "application/pdf"
        errors.add(:pdfs, "chỉ cho phép file PDF")
      end
    end
  end

  def pdfs_size
    pdfs.each do |pdf|
      if pdf.byte_size > 100.megabytes
        errors.add(:pdfs, "mỗi file tối đa 100MB")
      end
    end
  end
end
