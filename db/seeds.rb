puts "Seeding database..."

# ========== ADMIN ==========
admin = User.create!(
  full_name: "System Admin",
  email: "admin@ielts.com",
  password: "123456",
  role: :admin
)

# ========== TEACHERS ==========
10.times do |i|
  teacher = User.create!(
    full_name: "Teacher #{i + 1}",
    email: "teacher#{i + 1}@ielts.com",
    password: "123456",
    role: :teacher
  )

  TeacherProfile.create!(
    user: teacher,
    bio: "Giáo viên IELTS với hơn #{i + 3} năm kinh nghiệm",
    expertise: "IELTS Speaking",
    experience_years: i + 3
  )
end

# ========== STUDENTS ==========
30.times do |i|
  User.create!(
    full_name: "Student #{i + 1}",
    email: "student#{i + 1}@ielts.com",
    password: "123456",
    role: :student
  )
end

Course.destroy_all
Course.create!([
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

])



puts "Done seeding!"
