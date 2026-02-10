require "rails_helper"

RSpec.describe "Students::SpeakingAttempts", type: :request do

  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:topic) { create(:speaking_topic) }

  before do
    sign_in user
  end

  it "creates speaking attempt" do

    file = fixture_file_upload(
      Rails.root.join("spec/fixtures/audio.webm"),
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

  end
end
