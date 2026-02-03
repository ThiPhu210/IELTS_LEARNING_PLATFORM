require "rails_helper"

RSpec.describe "Root routing", type: :request do
  let(:user) { create(:user, role: :student) }

  it "shows homepage for unauthenticated user" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("IELTS") # hoặc nội dung homepage
  end

  it "redirects authenticated student via dashboard redirect" do
    sign_in user
    get root_path

    expect(response).to have_http_status(:found)
    expect(response.location).to include("/dashboard")
  end
end
