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

puts "Done seeding!"
