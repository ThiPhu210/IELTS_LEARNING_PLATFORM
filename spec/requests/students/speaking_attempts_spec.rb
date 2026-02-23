require "rails_helper"

RSpec.describe "Students::SpeakingAttempts", type: :request do
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:topic) { create(:speaking_topic) }

  before do
    sign_in user

    # Stub AWS S3
    fake_obj = double("s3_obj", put: true, public_url: "https://fake-audio-url.com/audio.webm")
    fake_bucket = double("bucket", object: fake_obj)
    fake_s3 = double("s3", bucket: fake_bucket)
    allow(Aws::S3::Resource).to receive(:new).and_return(fake_s3)

    # Stub BedrockService thay vì SpeakingEvaluateJob
    allow(BedrockService).to receive(:evaluate_speaking).and_return({
      "overall" => 7.0,
      "fluency" => 7.0,
      "lexical" => 6.5,
      "grammar" => 7.0,
      "pronunciation" => 6.5,
      "feedback" => "Good job!"
    })

    # Stub mailer
    allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
  end

  it "creates speaking attempt successfully" do
    file = fixture_file_upload("audio.webm", "audio/webm")

    post "/students/speaking_attempts",
         params: {
           audio: file,
           speaking_topic_id: topic.id,
           course_id: course.id,
           part: "part2"
         }

    expect(response).to have_http_status(:ok)

    attempt = SpeakingAttempt.last
    expect(attempt.user).to eq(user)
    expect(attempt.course).to eq(course)
    expect(attempt.speaking_topic).to eq(topic)
    expect(attempt.status).to eq("evaluated")  # đổi từ "processing" → "evaluated"
    expect(attempt.audio_url).to be_present
    expect(attempt.overall_band).to eq(7.0)
  end
end
