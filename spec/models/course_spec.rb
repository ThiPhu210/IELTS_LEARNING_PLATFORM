# spec/models/course_spec.rb
require "rails_helper"

RSpec.describe Course, type: :model do
  describe "associations" do
    it { should have_many(:course_accesses) }
    it { should have_many(:orders) }
    it { should have_many(:users).through(:orders) }
    it { should have_many(:course_sections).dependent(:destroy) }
  end


  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:band_min) }
    it { should validate_presence_of(:band_max) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:duration_days) }
    it { should validate_presence_of(:status) }
  end

  describe "scopes" do
    it "returns only published courses" do
      draft = create(:course, status: :draft)
      published = create(:course, status: :published)

      expect(Course.published_courses).to contain_exactly(published)
    end
  end
end
