class UserMailer < ApplicationMailer
  default from: "IELTS Platform <no-reply@ielts-platform.com>"

  def welcome_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Welcome to IELTS Learning Platform 🎉"
    )
  end
end
