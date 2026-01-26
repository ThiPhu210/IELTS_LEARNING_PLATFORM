require "rails_helper"

RSpec.describe "User Logout", type: :request do
  let!(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "DELETE /users/sign_out" do
    it "logs out successfully" do
      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
    end
  end
end
