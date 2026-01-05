class TeacherProfile < ApplicationRecord
  belongs_to :user

  validates :expertise, presence: true
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }
  has_one_attached :avatar
end
