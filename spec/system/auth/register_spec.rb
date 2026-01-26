# require "rails_helper"

# RSpec.describe "User Registration", type: :system do
#   before do
#     driven_by(:rack_test)
#   end

#   it "allows a new student to register" do
#     visit new_user_registration_path

#     fill_in "user[full_name]", with: "Nguyen Van A"
#     fill_in "user[email]", with: "newuser@example.com"
#     fill_in "user[password]", with: "password123"
#     fill_in "user[password_confirmation]", with: "password123"

#     click_button "Create account"

#     user = User.last
#     expect(user).to be_present
#     expect(user.student_role?).to be true
#     expect(page).to have_current_path("/users/sign_in")
#   end

#   it "does not allow registration with existing email" do
#     create(:user, email: "exist@example.com")

#     visit new_user_registration_path

#     fill_in "user[full_name]", with: "Another User"
#     fill_in "user[email]", with: "exist@example.com"
#     fill_in "user[password]", with: "password123"
#     fill_in "user[password_confirmation]", with: "password123"

#     click_button "Create account"

#     expect(page).to have_content("Email has already been taken")
#   end
# end
