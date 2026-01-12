class UserMailer < ApplicationMailer
  default from: "IELTS Platform <no-reply@ielts-platform.com>"
  def confirmation_email(user)
    @user = user
    Rails.logger.info "Mailer default_url_options: #{Rails.application.config.action_mailer.default_url_options.inspect}"
    @url  = confirm_email_url(token: @user.confirmation_token)
    mail(to: @user.email, subject: "Confirm your account")
  end
end
