require "rails_helper"

RSpec.describe Lesson, type: :model do
  describe "associations" do
    it { should belong_to(:course_section) }
    it { should have_one_attached(:video) }
    it { should have_many_attached(:pdfs) }
  end

  describe "validations" do
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_numericality_of(:duration).is_greater_than(0).allow_nil }
  end

  describe "custom validations" do
    let(:lesson) { build(:lesson, title: "Test Lesson") }

    context "video validations" do
      it "adds error if video type is not mp4" do
        lesson.video.attach(io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
                            filename: "test.txt",
                            content_type: "text/plain")
        lesson.valid?
        expect(lesson.errors[:video]).to include("chỉ cho phép MP4")
      end
    end

    context "pdf validations" do
      it "adds error if pdf type is not application/pdf" do
        lesson.pdfs.attach(io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
                           filename: "test.txt",
                           content_type: "text/plain")
        lesson.valid?
        expect(lesson.errors[:pdfs]).to include("chỉ cho phép file PDF")
      end
    end
  end

  describe "#video_thumbnail" do
    it "returns nil if no video attached" do
      lesson = build(:lesson)
      expect(lesson.video_thumbnail).to be_nil
    end
  end
end
