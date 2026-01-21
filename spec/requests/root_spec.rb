require "rails_helper"

RSpec.describe "Root redirect", type: :request do
  let(:user) { create(:user, role: :student) }

  it "redirects authenticated student to students dashboard" do
    sign_in user
    get root_path
    expect(response).to redirect_to(students_dashboard_path)
  end

  it "redirects unauthenticated user to sign in" do
    get root_path
    expect(response).to redirect_to("/users/sign_in")
  end
end
