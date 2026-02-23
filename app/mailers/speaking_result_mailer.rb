class SpeakingResultMailer < ApplicationMailer
  default from: "no-reply@yourapp.com"

  def send_result(attempt)
    @attempt = attempt
    @user = attempt.user

    mail(
      to: @user.email,
      subject: "Your Speaking Evaluation Result"
    )
  end
end
