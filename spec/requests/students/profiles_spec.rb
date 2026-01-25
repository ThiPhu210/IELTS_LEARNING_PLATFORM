require "rails_helper"

RSpec.describe "Students::Profiles", type: :request do
  let(:student) { create(:user, role: :student) }

  before do
    sign_in student
  end

  describe "GET /students/profile/edit" do
    it "renders edit page" do
      get edit_students_profile_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /students/profile" do
    it "updates full name" do
      patch students_profile_path, params: {
        user: { full_name: "Nguyen Thi Phu" }
      }

      expect(response).to redirect_to(students_dashboard_path)
      expect(student.reload.full_name).to eq("Nguyen Thi Phu")
    end

    it "requires email reconfirmation when changing email" do
      patch students_profile_path, params: {
        user: { email: "new@mail.com" }
      }

      student.reload
      expect(student.unconfirmed_email).to eq("new@mail.com")
      expect(student.email).not_to eq("new@mail.com")
    end

    it "does not crash when avatar uploaded but update fails" do
      patch students_profile_path, params: {
        user: {
          email: "invalid_email",
          thumbnail: fixture_file_upload("avatar.png", "image/png")
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
    it "cannot update another user profile" do
        other = create(:user)

        patch students_profile_path, params: {
          user: { full_name: "Hacker" },
          id: other.id
        }

        expect(student.reload.full_name).not_to eq("Hacker")
      end
  end
end
