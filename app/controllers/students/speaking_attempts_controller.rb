class Students::SpeakingAttemptsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :authenticate_user!

  def create
    audio = params[:audio]

    key = "speaking/#{SecureRandom.uuid}.webm"
    s3  = Aws::S3::Resource.new
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

    result = BedrockService.evaluate_speaking(attempt.transcript)

    attempt.update!(
      overall_band: result["overall"],
      fluency_score: result["fluency"],
      lexical_score: result["lexical"],
      grammar_score: result["grammar"],
      pronunciation_score: result["pronunciation"],
      feedback: result["feedback"],
      strengths: result["strengths"] || [],
      improvements: result["improvements"] || [],
      sample_correction: result["sample_correction"],
      status: "evaluated"
    )

    SpeakingResultMailer.result_email(attempt).deliver_later

    render json: {
      overall: attempt.overall_band,
      fluency: attempt.fluency_score,
      lexical: attempt.lexical_score,
      grammar: attempt.grammar_score,
      pronunciation: attempt.pronunciation_score,
      feedback: attempt.feedback,
      strengths: attempt.strengths,
      improvements: attempt.improvements,
      sample_correction: attempt.sample_correction
    }

  rescue => e
    attempt&.update(status: "failed")

    render json: { error: "AI evaluation failed: #{e.message}" },
           status: :unprocessable_entity
  end
end
