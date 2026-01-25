require "rails_helper"

RSpec.describe "User Login", type: :request do
  let!(:user) { create(:user, role: :student) }

  describe "POST /users/sign_in" do
    context "valid credentials" do
      it "logs in successfully" do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "password123"
          }
        }

        expect(response).to redirect_to(students_dashboard_path)
      end
    end

    context "invalid credentials" do
      it "fails login" do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "wrongpassword"
          }
        }

        expect(response.body).to include("Invalid Email or password")
      end
    end
  end
end
