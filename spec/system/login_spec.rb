require "rails_helper"

RSpec.describe "User login", type: :system do
  let!(:admin)   { User.create!(full_name: "Admin User", email: "admin@example.com", password: "password", role: :admin) }
  let!(:teacher) { User.create!(full_name: "Teacher User", email: "teacher@example.com", password: "password", role: :teacher) }
  let!(:student) { User.create!(full_name: "Student User", email: "student@example.com", password: "password", role: :student) }

  before do
    driven_by(:rack_test)
  end

  it "allows admin to login and redirect to admin dashboard" do
    visit login_path
    fill_in "email", with: admin.email
    fill_in "password", with: "password"
    click_button "Login"

    expect(page).to have_current_path(admin_dashboard_path)
    expect(page).to have_content(/Admin Dashboard/i)

  end

  it "allows teacher to login and redirect to teacher dashboard" do
    visit login_path
    fill_in "email", with: teacher.email
    fill_in "password", with: "password"
    click_button "Login"

    expect(page).to have_current_path(teacher_dashboard_path)
    expect(page).to have_content("Welcome, #{teacher.full_name}")
  end

  it "allows student to login and redirect to student dashboard" do
    visit login_path
    fill_in "email", with: student.email
    fill_in "password", with: "password"
    click_button "Login"

    expect(page).to have_current_path(student_dashboard_path)
    expect(page).to have_content("Welcome, #{student.full_name}")
  end

  it "fails login with wrong credentials" do
    visit login_path
    fill_in "email", with: "wrong@example.com"
    fill_in "password", with: "wrongpass"
    click_button "Login"

    expect(page).to have_content("Email hoặc mật khẩu không đúng")

  end
end
