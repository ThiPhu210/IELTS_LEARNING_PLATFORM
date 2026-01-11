class CourseSection < ApplicationRecord
  belongs_to :course
  has_rich_text :title
  has_rich_text :description
  has_many_attached :files

  validates :title, presence: true
  validate :files_size_limit
  validate :files_type

def files_type
  files.each do |file|
    unless file.content_type.in?(%w[
      application/pdf
      image/png
      image/jpg
      image/jpeg
    ])
      errors.add(:files, "Chỉ cho phép PDF hoặc hình ảnh")
    end
  end
end

  def files_size_limit
    files.each do |file|
      if file.byte_size > 200.megabytes
        errors.add(:files, "File tối đa 200MB")
      end
    end
  end
end
