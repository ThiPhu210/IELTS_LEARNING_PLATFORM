puts "Seeding database..."

# ========== ADMIN ==========
admin = User.find_or_create_by!(email: "admin@ielts.com") do |u|
  u.full_name = "System Admin"
  u.password  = "123456"
  u.role      = :admin
  u.confirmed = true
  u.confirmed_at = Time.current
  u.confirmation_token = nil
end

# ========== TEACHERS ==========
10.times do |i|
  teacher = User.find_or_create_by!(email: "teacher#{i + 1}@ielts.com") do |u|
    u.full_name = "Teacher #{i + 1}"
    u.password  = "123456"
    u.role      = :teacher
    u.confirmed = true
    u.confirmed_at = Time.current
    u.confirmation_token = nil
  end

  TeacherProfile.find_or_create_by!(user: teacher) do |tp|
    tp.bio              = "Giáo viên IELTS với hơn #{i + 3} năm kinh nghiệm"
    tp.expertise        = "IELTS Speaking"
    tp.experience_years = i + 3
  end
end

# ========== STUDENTS ==========
30.times do |i|
  User.find_or_create_by!(email: "student#{i + 1}@ielts.com") do |u|
    u.full_name = "Student #{i + 1}"
    u.password  = "123456"
    u.role      = :student
    u.confirmed = true
    u.confirmed_at = Time.current
    u.confirmation_token = nil
  end
end

# ========== COURSES ==========\
courses = [
  {
    title: "IELTS Speaking Band 3.0 → 3.5",
    band_min: 3.0,
    band_max: 3.5,
    price: 399000,
    duration_days: 30,
    description: "Khóa nền tảng cho người mới bắt đầu",
    status: 1
  },
  {
    title: "IELTS Speaking Band 3.5 → 4.0",
    band_min: 3.5,
    band_max: 4.0,
    price: 449000,
    duration_days: 30,
    description: "Luyện phát âm và từ vựng cơ bản",
    status: 1
  },
  {
    title: "IELTS Speaking Band 4.0 → 4.5",
    band_min: 4.0,
    band_max: 4.5,
    price: 499000,
    duration_days: 30,
    description: "Củng cố ngữ pháp và mẫu câu thường gặp",
    status: 1
  },
  {
    title: "IELTS Speaking Band 4.5 → 5.0",
    band_min: 4.5,
    band_max: 5.0,
    price: 549000,
    duration_days: 30,
    description: "Luyện Speaking Part 1 với chủ đề quen thuộc",
    status: 1
  },
  {
    title: "IELTS Speaking Band 5.0 → 5.5",
    band_min: 5.0,
    band_max: 5.5,
    price: 599000,
    duration_days: 40,
    description: "Chiến thuật trả lời Part 2 với cấu trúc rõ ràng",
    status: 1
  },
  {
    title: "IELTS Speaking Band 5.5 → 6.0",
    band_min: 5.5,
    band_max: 6.0,
    price: 649000,
    duration_days: 40,
    description: "Phát triển ý tưởng và mở rộng vốn từ",
    status: 1
  },
  {
    title: "IELTS Speaking Band 6.0 → 6.5",
    band_min: 6.0,
    band_max: 6.5,
    price: 699000,
    duration_days: 45,
    description: "Chiến thuật nâng cao Part 3",
    status: 1
  },
  {
    title: "IELTS Speaking Band 6.5 → 7.0",
    band_min: 6.5,
    band_max: 7.0,
    price: 749000,
    duration_days: 45,
    description: "Phân tích câu hỏi khó và luyện phản xạ",
    status: 1
  },
  {
    title: "IELTS Speaking Band 7.0 → 7.5",
    band_min: 7.0,
    band_max: 7.5,
    price: 799000,
    duration_days: 45,
    description: "Chiến thuật nâng band Speaking chuyên sâu",
    status: 1
  },
  {
    title: "IELTS Speaking Band 7.5 → 8.0",
    band_min: 7.5,
    band_max: 8.0,
    price: 849000,
    duration_days: 45,
    description: "Luyện phong thái tự tin và tự nhiên",
    status: 1
  },
  {
    title: "IELTS Speaking Band 8.0 → 8.5",
    band_min: 8.0,
    band_max: 8.5,
    price: 899000,
    duration_days: 45,
    description: "Chiến thuật trả lời chuyên nghiệp, logic",
    status: 1
  },
  {
    title: "IELTS Speaking Band 8.5 → 9.0",
    band_min: 8.5,
    band_max: 9.0,
    price: 999000,
    duration_days: 45,
    description: "Hoàn thiện kỹ năng để đạt band 9.0",
    status: 1
  },
  {
    title: "IELTS Speaking Band 4.0 → 5.0",
    band_min: 4.0,
    band_max: 5.0,
    price: 529000,
    duration_days: 35,
    description: "Khóa tổng hợp cho người mất gốc",
    status: 1
  },
  {
    title: "IELTS Speaking Band 5.0 → 6.0",
    band_min: 5.0,
    band_max: 6.0,
    price: 599000,
    duration_days: 40,
    description: "Luyện Speaking Part 1,2,3",
    status: 1
  },
  {
    title: "IELTS Speaking Band 6.0 → 7.0",
    band_min: 6.0,
    band_max: 7.0,
    price: 799000,
    duration_days: 45,
    description: "Chiến thuật nâng band Speaking",
    status: 1
  },
  {
    title: "IELTS Speaking Band 7.0 → 8.0",
    band_min: 7.0,
    band_max: 8.0,
    price: 899000,
    duration_days: 45,
    description: "Chiến thuật nâng band Speaking nâng cao",
    status: 1
  },
  {
    title: "IELTS Speaking Band 3.0 → 4.0",
    band_min: 3.0,
    band_max: 4.0,
    price: 449000,
    duration_days: 30,
    description: "Khóa nhập môn Speaking cho người mới",
    status: 1
  },
  {
    title: "IELTS Speaking Band 4.5 → 5.5",
    band_min: 4.5,
    band_max: 5.5,
    price: 579000,
    duration_days: 35,
    description: "Luyện tập phản xạ và phát âm",
    status: 1
  },
  {
    title: "IELTS Speaking Band 8.0 → 9.0",
    band_min: 8.0,
    band_max: 9.0,
    price: 999000,
    duration_days: 45,
    description: "Chiến thuật nâng band Speaking chuyên sâu",
    status: 1
  },
  {
    title: "Special Course: Improve Your Speaking Skills Fast",
    band_min: 7.0,
    band_max: 8.0,
    price: 999000,
    duration_days: 20,
    description: "Khóa đặc biệt giúp cải thiện kỹ năng nói nhanh chóng",
    status: 1
  }
]


courses.each do |attrs|
  Course.find_or_create_by!(title: attrs[:title]) do |c|
    c.assign_attributes(attrs)
  end
end

Rails.application.config.action_mailer.perform_deliveries = false
Sidekiq::Testing.inline! if defined?(Sidekiq::Testing)

puts "Done seeding!"
