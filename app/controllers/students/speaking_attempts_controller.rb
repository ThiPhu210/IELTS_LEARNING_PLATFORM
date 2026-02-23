class Students::SpeakingAttemptsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :authenticate_user!
def create
  audio = params[:audio]
  key = "speaking/#{SecureRandom.uuid}.webm"
  s3 = Aws::S3::Resource.new
  obj = s3.bucket(ENV["AWS_BUCKET"]).object(key)
  obj.put(body: audio.read)

  attempt = SpeakingAttempt.create!(
    user: current_user,
    course_id: params[:course_id],
    speaking_topic_id: params[:speaking_topic_id],
    part: params[:part],
    transcript: params[:transcript],
    audio_url: obj.public_url,
    status: "processing"
  )

  # Gọi Bedrock AI ngay
  result = BedrockService.evaluate_speaking(attempt.transcript)

  attempt.update!(
    score: result["overall"],
    fluency: result["fluency"],
    lexical: result["lexical"],
    grammar: result["grammar"],
    pronunciation: result["pronunciation"],
    feedback: result["feedback"],
    status: "evaluated"
  )

  SpeakingResultMailer.result_email(attempt).deliver_later

  render json: {
    overall: result["overall"],
    fluency: result["fluency"],
    lexical: result["lexical"],
    grammar: result["grammar"],
    pronunciation: result["pronunciation"],
    feedback: result["feedback"]
  }

rescue => e
  Rails.logger.error "Bedrock error: #{e.message}"
  attempt&.update!(status: "failed")
  render json: { error: "AI evaluation failed" }, status: :unprocessable_entity
end
end
