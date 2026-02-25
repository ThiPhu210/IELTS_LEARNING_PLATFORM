class Students::SpeakingAttemptsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :authenticate_user!

  def create
    audio = params[:audio]

    return render json: { error: "Audio file missing" }, status: :unprocessable_entity if audio.blank?

    key = "speaking/#{SecureRandom.uuid}.webm"

    s3 = Aws::S3::Resource.new(
      region: ENV["AWS_REGION"]
    )

    obj = s3.bucket("ielts-learning-platform-uploads").object(key)
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

    # =============================
    # Call Bedrock AI
    # =============================
    result = BedrockService.evaluate_speaking(attempt.transcript)

    # Safe parsing
    strengths_text = Array(result["strengths"]).join("\n• ")
    improvements_text = Array(result["improvements"]).join("\n• ")

    attempt.update!(
      overall_band: result["overall"],
      fluency_score: result["fluency"],
      lexical_score: result["lexical"],
      grammar_score: result["grammar"],
      pronunciation_score: result["pronunciation"],
      strength: strengths_text.presence,
      improvement: improvements_text.presence,
      sample_correction: result["sample_correction"],
      feedback: result["feedback"],
      status: "evaluated"
    )

    SpeakingResultMailer.result_email(attempt).deliver_later

    render json: {
      overall: attempt.overall_band,
      fluency: attempt.fluency_score,
      lexical: attempt.lexical_score,
      grammar: attempt.grammar_score,
      pronunciation: attempt.pronunciation_score,
      strength: attempt.strength,
      improvement: attempt.improvement,
      sample_correction: attempt.sample_correction,
      feedback: attempt.feedback
    }

  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}"
    attempt&.update(status: "failed")
    render json: { error: "AI returned invalid JSON" }, status: :unprocessable_entity

  rescue => e
    Rails.logger.error "Bedrock error: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    attempt&.update(status: "failed")
    render json: { error: "AI evaluation failed" }, status: :unprocessable_entity
  end
end
