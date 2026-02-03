require "rails_helper"

RSpec.describe "Root homepage", type: :request do
  let(:user) { create(:user, role: :student) }

  it "renders homepage for authenticated student" do
    sign_in user
    get root_path
    expect(response).to have_http_status(:ok)
  end

  it "renders homepage for unauthenticated user" do
    get root_path
    expect(response).to have_http_status(:ok)
  end
end
