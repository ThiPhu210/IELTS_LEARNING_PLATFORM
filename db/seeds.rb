puts "Seeding database..."

# ========== ADMIN ==========
admin = User.find_or_create_by!(email: "admin@ielts.com") do |u|
  u.full_name = "System Admin"
  u.password  = "123456"
  u.role      = :admin
end

# ========== TEACHERS ==========
10.times do |i|
  teacher = User.find_or_create_by!(email: "teacher#{i + 1}@ielts.com") do |u|
    u.full_name = "Teacher #{i + 1}"
    u.password  = "123456"
    u.role      = :teacher
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
  end
end

# ========== COURSES ==========
courses = [
  {
    title: "IELTS Speaking Band 5.0 → 6.0",
    band_min: 5.0,
    band_max: 6.0,
    price: 499_000,
    duration_days: 30,
    description: "Luyện Speaking Part 1,2,3 cho người mất gốc",
    status: 1
  },
  {
    title: "IELTS Speaking Band 6.0 → 7.0",
    band_min: 6.0,
    band_max: 7.0,
    price: 799_000,
    duration_days: 45,
    description: "Chiến thuật nâng band Speaking",
    status: 1
  },
  {
    title: "IELTS Speaking Band 7.0 → 8.0",
    band_min: 7.0,
    band_max: 8.0,
    price: 899_000,
    duration_days: 45,
    description: "Chiến thuật nâng band Speaking",
    status: 1
  }
]

courses.each do |attrs|
  Course.find_or_create_by!(title: attrs[:title]) do |c|
    c.assign_attributes(attrs)
  end
end

puts "Done seeding!"
