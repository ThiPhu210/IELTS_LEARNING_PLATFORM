# require "rails_helper"

# RSpec.describe "Password Reset", type: :system do
#   before do
#     driven_by(:selenium_chrome)
#   end

#   let!(:user) { create(:user, email: "lost@example.com", role: :student, password: "oldpassword") }

#   it "allows user to request password reset and set new password" do
#     visit new_user_password_path
#     fill_in "user_email", with: user.email
#     click_button "Send reset password instructions"
#     token = Devise.token_generator.generate(User, :reset_password_token)
#     user.update!(
#       reset_password_token: token[1],
#       reset_password_sent_at: Time.current
#     )
#     visit edit_user_password_path(reset_password_token: token[0])
#     fill_in "user[password]", with: "newpassword123"
#     fill_in "user[password_confirmation]", with: "newpassword123"
#     click_button "Change my password"
#     expect(page).to have_current_path(students_dashboard_path)
#   end


#   it "does not create reset token for non-existent email" do
#     visit new_user_password_path
#     fill_in "Email", with: "notfound@example.com"
#     click_button "Send reset password instructions"
#     expect(page).to have_content("Email not found")
#   end

#   it "does not allow reset with expired token" do
#     token = user.send_reset_password_instructions
#     user.update!(reset_password_sent_at: 3.days.ago)
#     visit edit_user_password_path(reset_password_token: token)
#     fill_in "user[password]", with: "newpassword123"
#     fill_in "user[password_confirmation]", with: "newpassword123"
#     click_button "Change my password"
#     expect(page).to have_content("Reset password token has expired, please request a new one")
#   end


#   it "shows error when password confirmation does not match" do
#     token = user.send_reset_password_instructions
#     visit edit_user_password_path(reset_password_token: token)
#     fill_in "user[password]", with: "newpassword123"
#     fill_in "user[password_confirmation]", with: "mismatchpassword123"
#     click_button "Change my password"
#     expect(page).to have_content("doesn't match")
#   end
#   it "does not allow login with old password after reset" do
#     old_password = "oldpassword"
#     new_password = "newpassword123"

#     user.update!(password: old_password)

#     ActionMailer::Base.deliveries.clear
#     user.send_reset_password_instructions

#     mail  = ActionMailer::Base.deliveries.last
#     token = mail.body.encoded.match(/reset_password_token=([^"]+)/)[1]

#     visit edit_user_password_path(reset_password_token: token)

#     fill_in "user[password]", with: new_password
#     fill_in "user[password_confirmation]", with: new_password
#     click_button "Change my password"
#     page.execute_script <<~JS
#   document.querySelector("form input[name='_method'][value='delete']").closest("form").submit();
# JS

#     visit new_user_session_path
#     fill_in "Email", with: user.email
#     fill_in "Password", with: old_password
#     click_button "Login to your account"

#     expect(current_path).to eq(new_user_session_path)
#   end
# end
