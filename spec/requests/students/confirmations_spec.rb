require "rails_helper"

RSpec.describe "Email confirmation", type: :request do
  let(:student) { create(:user, :confirmed) }

  it "confirms new email after clicking confirmation link" do
    # 1️⃣ Đổi email → Devise sinh token
    student.update!(email: "new_email@test.com")

    # 2️⃣ Reload để lấy token
    student.reload

    token = student.confirmation_token
    expect(token).to be_present

    # 3️⃣ Gọi link confirm
    get user_confirmation_path(confirmation_token: token)

    student.reload

    # 4️⃣ Assert
    expect(student.email).to eq("new_email@test.com")
    expect(student.unconfirmed_email).to be_nil
    expect(student.confirmed?).to be true
  end
end
