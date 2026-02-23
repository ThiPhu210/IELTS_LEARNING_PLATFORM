class SpeakingResultMailer < ApplicationMailer
  def result_email(attempt)
    @attempt = attempt
    @user = attempt.user
    @course = attempt.course

    mail(
      to: @user.email,
      subject: "🎤 Your IELTS Speaking Result - Band #{@attempt.overall_band}"
    )
  end
end
