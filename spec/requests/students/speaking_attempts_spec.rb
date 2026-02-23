require "rails_helper"

RSpec.describe "Students::SpeakingAttempts", type: :request do
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:topic) { create(:speaking_topic) }

  let(:fake_ai_result) do
    {
      "overall" => 7.0,
      "fluency" => 7.0,
      "lexical" => 6.5,
      "grammar" => 7.0,
      "pronunciation" => 6.5,
      "feedback" => "Good job!"
    }
  end

  before do
    sign_in user

    # Stub S3
    fake_obj = double("s3_obj", put: true, public_url: "https://fake-s3.com/audio.webm")
    fake_bucket = double("bucket", object: fake_obj)
    fake_s3 = double("s3", bucket: fake_bucket)
    allow(Aws::S3::Resource).to receive(:new).and_return(fake_s3)

    # Stub Bedrock AI
    allow(BedrockService).to receive(:evaluate_speaking).and_return(fake_ai_result)

    # Stub Mailer hoàn toàn
    fake_mail = double("mail", deliver_later: true)
    allow(SpeakingResultMailer).to receive(:result_email).and_return(fake_mail)
  end

  it "creates speaking attempt and returns AI scores" do
    file = fixture_file_upload("audio.webm", "audio/webm")

    post "/students/speaking_attempts",
         params: {
           audio: file,
           speaking_topic_id: topic.id,
           course_id: course.id,
           part: "part2",
           transcript: "I think technology is very important nowadays."
         }

    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json["overall"]).to eq(7.0)
    expect(json["fluency"]).to eq(7.0)
    expect(json["feedback"]).to eq("Good job!")

    attempt = SpeakingAttempt.last
    expect(attempt.user).to eq(user)
    expect(attempt.course).to eq(course)
    expect(attempt.speaking_topic).to eq(topic)
    expect(attempt.status).to eq("evaluated")
    expect(attempt.overall_band).to eq(7.0)
    expect(attempt.audio_url).to be_present
  end

  it "returns error when AI fails" do
    allow(BedrockService).to receive(:evaluate_speaking).and_raise(StandardError, "Bedrock timeout")

    file = fixture_file_upload("audio.webm", "audio/webm")

    post "/students/speaking_attempts",
         params: {
           audio: file,
           speaking_topic_id: topic.id,
           course_id: course.id,
           part: "part2"
         }

    expect(response).to have_http_status(:unprocessable_entity)

    json = JSON.parse(response.body)
    expect(json["error"]).to include("AI evaluation failed")

    expect(SpeakingAttempt.last.status).to eq("failed")
  end
end
