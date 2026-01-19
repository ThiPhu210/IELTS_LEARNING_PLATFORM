class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    mail = super
    mail.deliver_later
    mail
  end

  def reset_password_instructions(record, token, opts = {})
    mail = super
    mail.deliver_later
    mail
  end

  def unlock_instructions(record, token, opts = {})
    mail = super
    mail.deliver_later
    mail
  end
end
