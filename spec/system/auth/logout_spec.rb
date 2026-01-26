require "rails_helper"

RSpec.describe "Logout", type: :system do
  let(:student) { create(:user, confirmed_at: Time.current, password: "password123") }

  before do
    driven_by(:selenium_chrome_headless)
  end

  def login
    visit new_user_session_path
    fill_in "Email", with: student.email
    fill_in "Password", with: "password123"
    click_button "Login to your account"
    expect(page).to have_current_path(students_dashboard_path)
  end

  it "logs out successfully" do
    login

    page.execute_script <<~JS
  document.querySelector("form input[name='_method'][value='delete']").closest("form").submit();
    JS

    expect(page).to have_current_path(new_user_session_path)
  end
end
