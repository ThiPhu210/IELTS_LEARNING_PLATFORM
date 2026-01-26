# require "rails_helper"

# RSpec.describe "User Login", type: :system do
#   let(:user) { create(:user, role: :student) }

#   it "allows student to login successfully" do
#     visit new_user_session_path

#     fill_in "Email", with: user.email
#     fill_in "Password", with: "password123"

#     click_button "Login to your account"

#     expect(page).to have_current_path(students_dashboard_path)
#   end


#   it "does not allow login with wrong password" do
#     visit new_user_session_path
#     fill_in "Email", with: user.email
#     fill_in "Password", with: "wrongpassword"
#     click_button "Login to your account"

#     expect(page).to have_current_path(new_user_session_path)
#     expect(current_path).to eq(new_user_session_path)
#   end
# end
