# require "rails_helper"

# RSpec.describe "User registration", type: :system do
#   before do
#     driven_by(:rack_test)
#   end

#   it "allows a new student to register and redirects to student dashboard" do
#     visit register_path
#     fill_in "Full name", with: "New Student"
#     fill_in "Email", with: "new_student@example.com"
#     fill_in "Password", with: "password"
#     click_button "Register"

#     user = User.find_by(email: "new_student@example.com")
#     expect(user).not_to be_nil
#     expect(page).to have_current_path(student_dashboard_path)
#     expect(page).to have_content("Welcome, New Student")
#   end
# end


require "rails_helper"

RSpec.describe "User registration", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "allows a new student to register" do
    visit register_path
    fill_in "Full name", with: "New Student"
    fill_in "Email", with: "newstudent@example.com"
    fill_in "Password", with: "password"
    click_button "Register"

    expect(page).to have_current_path(student_dashboard_path)
    expect(page).to have_content("Welcome, New Student")
  end

  it "does not allow registration with existing email" do
    User.create!(full_name: "Existing", email: "exist@example.com", password: "password", role: :student)

    visit register_path
    fill_in "Full name", with: "Test User"
    fill_in "Email", with: "exist@example.com"
    fill_in "Password", with: "password"
    click_button "Register"

    expect(page).to have_content("Email has already been taken")
  end

  it "shows validation errors if fields missing" do
    visit register_path
    click_button "Register"

    expect(page).to have_content("Email can't be blank")
    expect(page).to have_content("Full name can't be blank")
    expect(page).to have_content("Password can't be blank")
  end
end
