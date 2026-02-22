class SpeakingEvaluateJob < ApplicationJob
  queue_as :default

  def perform(attempt_id)
    attempt = SpeakingAttempt.find(attempt_id)

    # 1️⃣ Transcribe audio (bạn đang có AwsTranscribeService rồi)
    transcript = AwsTranscribeService.call(attempt.audio_url)

    # 2️⃣ Gọi Bedrock
    result = BedrockService.evaluate_speaking(transcript)

    # 3️⃣ Update DB
    attempt.update!(
      transcript: transcript,
      overall_band: result["overall"],
      fluency_score: result["fluency"],
      lexical_score: result["lexical"],
      grammar_score: result["grammar"],
      pronunciation_score: result["pronunciation"],
      feedback: result["feedback"],
      status: "completed"
    )

    # 4️⃣ Gửi mail
    SpeakingResultMailer.send_result(attempt).deliver_now

  rescue => e
    attempt.update(status: "failed") if attempt
    Rails.logger.error e.message
  end
end
