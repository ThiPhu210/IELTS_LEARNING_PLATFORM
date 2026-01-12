class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@ielts-platform.test"

  default_url_options[:host] = "host.docker.internal"
  default_url_options[:port] = 3000

  layout "mailer"
end
