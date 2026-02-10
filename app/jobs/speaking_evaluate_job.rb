class SpeakingEvaluateJob < ApplicationJob
  def perform(attempt_id)

    attempt = SpeakingAttempt.find(attempt_id)

    transcript = AwsTranscribeService.call(attempt.audio_url)

    result = BedrockService.evaluate_speaking(transcript)

    attempt.update!(
      transcript: transcript,
      overall_band: result[:overall],
      fluency_score: result[:fluency],
      lexical_score: result[:lexical],
      grammar_score: result[:grammar],
      pronunciation_score: result[:pronunciation],
      feedback: result[:feedback],
      status: "completed"
    )

  rescue
    attempt.update!(status: "failed")
  end
end
