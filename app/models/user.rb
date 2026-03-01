class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable
  has_one_attached :thumbnail
  after_commit :compress_thumbnail, if: :thumbnail_attached_changed?
  # ===== associations =====
  has_many :orders, dependent: :destroy
  has_many :courses, through: :orders
  has_many :course_accesses
  has_many :speaking_attempts
  has_many :course_progresses
  has_many :achievements, dependent: :destroy
  has_many :chat_messages, dependent: :destroy  # ← THÊM DÒNG NÀY
  enum :role, { admin: 0, student: 1 }, suffix: true
  scope :students, -> { where(role: :student) }
  # ===== validations =====
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :full_name, presence: true
  validates :password, presence: true, on: :create
  validates :school, presence: true, if: :student_role?, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :feedback, length: { maximum: 1000 }, allow_blank: true
  validates :phone,
            format: { with: /\A0\d{9,10}\z/, message: "Phone number must have 10 digits" },
            allow_blank: true
  validate :thumbnail_type
  after_initialize :set_default_role, if: :new_record?
  def set_default_role
    self.role ||= "student"
  end
  def has_course_access?(course)
    course_accesses.exists?(
      course_id: course.id,
      status: CourseAccess.statuses[:active]
    )
  end
  private
  def thumbnail_attached_changed?
    thumbnail.attached? && thumbnail.blob&.new_record?
  end
  def compress_thumbnail
    downloaded = Tempfile.new([ "original", ".jpg" ])
    downloaded.binmode
    downloaded.write(thumbnail.download)
    downloaded.rewind
    compressed = ImageCompressor.compress(downloaded)
    thumbnail.detach
    thumbnail.attach(
      io: compressed,
      filename: "thumbnail.jpg",
      content_type: "image/jpeg"
    )
  ensure
    downloaded.close!
  end
  def thumbnail_type
    return unless thumbnail.attached?
    allowed_types = %w[
      image/png
      image/jpg
      image/jpeg
      image/webp
    ]
    unless allowed_types.include?(thumbnail.blob.content_type)
      thumbnail.purge
      errors.add(:thumbnail, "chỉ cho phép ảnh PNG, JPG, JPEG, WEBP")
    end
  end
end
