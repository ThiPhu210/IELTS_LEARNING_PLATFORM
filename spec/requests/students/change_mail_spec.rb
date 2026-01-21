require "rails_helper"

RSpec.describe "Students::Profiles", type: :request do
  let(:student) { create(:user, :confirmed) }

  before do
    sign_in student
    ActionMailer::Base.deliveries.clear
  end

  describe "PATCH /students/profile" do
    it "requires email confirmation when changing email" do
      old_email = student.email

      patch students_profile_path, params: {
        user: { email: "new@mail.com" }
      }

      student.reload

      # 1️⃣ email CHƯA đổi
      expect(student.email).to eq(old_email)

      # 2️⃣ unconfirmed_email được set
      expect(student.unconfirmed_email).to eq("new@mail.com")

      # 3️⃣ gửi email
      expect(ActionMailer::Base.deliveries.size).to eq(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include("new@mail.com")
      expect(mail.subject).to match(/confirmation/i)
    end
  end
end
