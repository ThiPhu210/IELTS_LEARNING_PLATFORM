class Students::SpeakingAttemptsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :authenticate_user!
  def create
    Rails.logger.info "=== SPEAKING ATTEMPT CREATE ==="
    audio = params[:audio]

    key = "speaking/#{SecureRandom.uuid}.webm"

    s3 = Aws::S3::Resource.new
    obj = s3.bucket(ENV["AWS_BUCKET"]).object(key)

    obj.put(body: audio.read)

    audio_url = obj.public_url

    attempt = SpeakingAttempt.create!(
      user: current_user,
      course_id: params[:course_id],
      speaking_topic_id: params[:speaking_topic_id],
      part: params[:part],
      audio_url: audio_url,
      status: "processing"
    )

    SpeakingEvaluateJob.perform_later(attempt.id)

    head :ok
  end
end
