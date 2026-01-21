require "rails_helper"

RSpec.describe "Authentication", type: :request do
  it "redirects unauthenticated user to login" do
    get students_dashboard_path
    expect(response).to redirect_to("/users/sign_in")
  end
end
