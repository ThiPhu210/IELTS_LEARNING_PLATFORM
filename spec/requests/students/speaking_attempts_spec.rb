require "rails_helper"

RSpec.describe "Students::SpeakingAttempts", type: :request do
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

  let(:user)   { create(:user) }
  let(:course) { create(:course) }
  let(:lesson) { create(:lesson, course: course) }
  let(:topic)  { create(:speaking_topic, lesson: lesson) }

  let(:fake_ai_result) do
    {
      "overall" => 7.0,
      "fluency" => 7.0,
      "lexical" => 6.5,
      "grammar" => 7.0,
      "pronunciation" => 6.5,
      "feedback" => "Good job!",
      "strengths" => ["Good fluency", "Clear structure"],
      "improvements" => ["Improve grammar accuracy"],
      "sample_correction" => "Technology plays an important role nowadays."
    }
  end

  before do
    sign_in user

    # Stub S3
    fake_obj = double("s3_obj", put: true, public_url: "https://fake-s3.com/audio.webm")
    fake_bucket = double("bucket", object: fake_obj)
    fake_s3 = double("s3", bucket: fake_bucket)

    allow(Aws::S3::Resource).to receive(:new).and_return(fake_s3)

    # Stub AI
    allow(BedrockService).to receive(:evaluate_speaking)
      .and_return(fake_ai_result)

    # Stub Mailer
    fake_mail = double("mail", deliver_later: true)
    allow(SpeakingResultMailer).to receive(:result_email)
      .and_return(fake_mail)

    # Stub ENV
    allow(ENV).to receive(:fetch).with("AWS_BUCKET")
      .and_return("fake-bucket")
  end

  describe "POST /students/speaking_attempts" do
    let(:file) do
      fixture_file_upload(
        Rails.root.join("spec/fixtures/files/audio.webm"),
        "audio/webm"
      )
    end

    it "creates speaking attempt with detailed AI feedback" do
      post "/students/speaking_attempts", params: {
        audio: file,
        speaking_topic_id: topic.id,
        course_id: course.id,
        part: "part2",
        transcript: "Technology is very important nowadays."
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["overall"]).to eq(7.0)
      expect(json["strengths"]).to include("Good fluency")
      expect(json["improvements"]).to include("Improve grammar accuracy")
      expect(json["sample_correction"]).to be_present

      attempt = SpeakingAttempt.last
      expect(attempt.status).to eq("evaluated")
      expect(attempt.strengths).to eq(["Good fluency", "Clear structure"])
      expect(attempt.improvements).to eq(["Improve grammar accuracy"])
      expect(attempt.sample_correction).to be_present
    end

    it "returns error when AI fails" do
      allow(BedrockService).to receive(:evaluate_speaking)
        .and_raise(StandardError, "Bedrock timeout")

      post "/students/speaking_attempts", params: {
        audio: file,
        speaking_topic_id: topic.id,
        course_id: course.id,
        part: "part2",
        transcript: "Technology is important."
      }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)

      expect(json["error"]).to include("AI evaluation failed")

      expect(SpeakingAttempt.last.status).to eq("failed")
    end
  end
end
