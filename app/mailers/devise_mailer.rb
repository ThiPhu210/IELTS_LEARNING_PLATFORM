class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts={})
    super.deliver_later
  end

  def reset_password_instructions(record, token, opts={})
    super.deliver_later
  end

  def unlock_instructions(record, token, opts={})
    super.deliver_later
  end
end
