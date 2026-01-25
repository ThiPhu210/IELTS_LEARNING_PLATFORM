# spec/models/course_access_spec.rb
require "rails_helper"
RSpec.describe CourseAccess, type: :model do
  describe "validations" do
    it "validates end_date > start_date" do
      access = build(:course_access, start_date: Time.current, end_date: 1.day.ago, status: :active)

      expect(access).not_to be_valid
    end

    it "validates uniqueness of user per course" do
      user = create(:user)
      course = create(:course)
      order1 = create(:order, user: user, course: course)
      order2 = create(:order, user: user, course: course)

      create(:course_access, user: user, course: course, order: order1, status: :active)
      dup = build(:course_access, user: user, course: course, order: order2, status: :active)

      expect(dup).not_to be_valid
    end
  end

  describe "scopes" do
    it "returns active accesses" do
      course = create(:course)
      user1 = create(:user)
      user2 = create(:user)
      order1 = create(:order, user: user1, course: course)
      order2 = create(:order, user: user2, course: course)

      active = create(:course_access, user: user1, course: course, order: order1, status: :active)
      expired = create(:course_access, user: user2, course: course, order: order2, status: :expired)

      expect(CourseAccess.active_access).to include(active)
      expect(CourseAccess.active_access).not_to include(expired)
    end
  end
end
