# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:courses).through(:orders) }
    it { should have_many(:course_accesses) }
    it { should have_one(:teacher_profile).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    subject { build(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:full_name) }
  end

  describe "devise confirmable" do
    it "is unconfirmed by default" do
      user = build(:user, confirmed_at: nil)
      expect(user.confirmed?).to eq(false)
    end
  end
end
