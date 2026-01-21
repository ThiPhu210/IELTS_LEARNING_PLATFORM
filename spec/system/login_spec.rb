require "rails_helper"

RSpec.describe "User Login", type: :system do
  let(:user) { create(:user, role: :student) }

  it "allows student to login successfully" do
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"

    click_button "Login to your account"

    expect(page).to have_current_path(students_dashboard_path)
  end
end
