# spec/models/order_spec.rb
require "rails_helper"

RSpec.describe Order, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:course) }
    it { should have_one(:payment).dependent(:destroy) }
    it { should have_one(:course_access).dependent(:destroy) }
  end


  describe "validations" do
    it { should validate_presence_of(:total_price) }
  end
end
