RSpec.describe "Remember me", type: :system do
  let(:student) do
    create(:user, password: "password123", confirmed_at: Time.current)
  end

  before do
    driven_by(:selenium_chrome_headless)
  end

  def login(remember:)
    visit new_user_session_path
    fill_in "Email", with: student.email
    fill_in "Password", with: "password123"
    check "Remember me" if remember
    click_button "Login to your account"
  end

  it "sets remember me cookie when checked" do
    login(remember: true)
    expect(page).to have_current_path(students_dashboard_path)

    cookie = page.driver.browser.manage.cookie_named("remember_user_token")
    expect(cookie).to be_present
  end

  it "does NOT set remember me cookie when unchecked" do
    login(remember: false)

    expect(page).to have_current_path(students_dashboard_path)

    expect {
      page.driver.browser.manage.cookie_named("remember_user_token")
    }.to raise_error(Selenium::WebDriver::Error::NoSuchCookieError)
  end
end
