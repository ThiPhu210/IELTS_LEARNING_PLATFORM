class Students::SpeakingAttemptsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :create

  def create
    audio = params[:audio]
    return render_audio_missing unless audio.present?

    attempt = create_attempt(audio)
    evaluate_with_ai!(attempt)
    SpeakingResultMailer.result_email(attempt).deliver_later
    render json: serialize_attempt(attempt), status: :ok
  rescue StandardError => e
    attempt&.update(status: "failed")
    Rails.logger.error("[SpeakingAttempt] Failed: #{e.class} — #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    render json: { error: "AI evaluation failed: #{e.message}" },
           status: :unprocessable_entity
  end

  private

  def create_attempt(audio)
    key = "speaking/#{SecureRandom.uuid}.webm"
    s3  = Aws::S3::Resource.new
    obj = s3.bucket(ENV.fetch("AWS_BUCKET")).object(key)
    obj.put(body: audio.read)

    SpeakingAttempt.create!(
      user: current_user,
      course_id: params[:course_id],
      speaking_topic_id: params[:speaking_topic_id],
      part: params[:part],
      transcript: params[:transcript],
      audio_url: obj.public_url,
      status: "processing"
    )
  end

  def evaluate_with_ai!(attempt)
    result = BedrockService.evaluate_speaking(attempt.transcript)
    attempt.update!(
      overall_band:       result["overall"],
      fluency_score:      result["fluency"],
      lexical_score:      result["lexical"],
      grammar_score:      result["grammar"],
      pronunciation_score: result["pronunciation"],
      feedback:           result["feedback"],
      strengths:          result["strengths"] || [],
      improvements:       result["improvements"] || [],
      sample_correction:  result["sample_correction"],
      status:             "evaluated"
    )
  end

  def serialize_attempt(attempt)
    {
      overall:           attempt.overall_band,
      fluency:           attempt.fluency_score,
      lexical:           attempt.lexical_score,
      grammar:           attempt.grammar_score,
      pronunciation:     attempt.pronunciation_score,
      feedback:          attempt.feedback,
      strengths:         attempt.strengths,
      improvements:      attempt.improvements,
      sample_correction: attempt.sample_correction
    }
  end

  def render_audio_missing
    render json: { error: "Audio file is required" },
           status: :unprocessable_entity
  end
end
