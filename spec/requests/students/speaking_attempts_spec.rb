require "rails_helper"

RSpec.describe "Students::SpeakingAttempts", type: :request do
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess::FixtureFile

  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:topic) { create(:speaking_topic) }

  before do
    sign_in user

    # 🔥 stub AWS S3
    fake_obj = double("s3_obj", put: true, public_url: "https://fake-audio-url.com/audio.webm")
    fake_bucket = double("bucket", object: fake_obj)
    fake_s3 = double("s3", bucket: fake_bucket)

    allow(Aws::S3::Resource).to receive(:new).and_return(fake_s3)

    # 🔥 không chạy background job thật
    allow(SpeakingEvaluateJob).to receive(:perform_later)
  end

  it "creates speaking attempt successfully" do

file = fixture_file_upload(
  "audio.webm",
  "audio/webm"
)


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
    expect(attempt.status).to eq("processing")
    expect(attempt.audio_url).to be_present
  end
end
