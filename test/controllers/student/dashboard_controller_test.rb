require "test_helper"

class Student::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get student_dashboard_index_url
    assert_response :success
  end
end
