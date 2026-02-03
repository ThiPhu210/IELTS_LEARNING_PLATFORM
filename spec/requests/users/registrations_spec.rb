require "rails_helper"

RSpec.describe "User Registration", type: :request do
  describe "POST /users" do
    context "valid params" do
      it "registers a new user" do
        expect {
          post user_registration_path, params: {
            user: {
              full_name: "Test User",
              email: "test@example.com",
              password: "password123",
              password_confirmation: "password123",
              phone: "0906270067",
              role: "student",
              school: "IELTS University"
            }
          }
        }.to change(User, :count).by(1)
        expect(response).to be_redirect
      end
    end

    context "invalid params" do
      it "does not register user" do
        post user_registration_path, params: {
          user: {
            email: "",
            password: "123",
            password_confirmation: "456"
          }
        }

        expect(response.body).to include("error")
      end
    end
  end
end
