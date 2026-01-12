class User < ApplicationRecord
  before_create :set_confirmation_token
  after_commit :send_confirmation_email, on: :create

  has_secure_password
  has_many :course_accesses
  has_many :courses, through: :course_accesses
  has_many :orders
  has_many :speaking_attempts
  has_many :course_progresses
  has_one :teacher_profile, dependent: :destroy
  accepts_nested_attributes_for :teacher_profile, allow_destroy: true

  enum :role, { admin: 0, teacher: 1, student: 2 }, suffix: true
  scope :teachers, -> { where(role: :teacher) }
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :full_name, presence: true
  validates :password, presence: true, on: :create

  def confirm!
    update!(
      confirmed: true,
      confirmed_at: Time.current,
      confirmation_token: nil
    )
  end

  private

  def send_confirmation_email
    UserMailer.confirmation_email(self).deliver_later
  end

  def set_confirmation_token
    self.confirmation_token ||= SecureRandom.hex(32)
  end
end
