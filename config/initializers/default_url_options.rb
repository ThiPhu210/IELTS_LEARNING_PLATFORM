host = ENV.fetch("APP_HOST") || "ielts-learning-platform.duckdns.org"

Rails.application.routes.default_url_options[:host] = host
Rails.application.routes.default_url_options[:protocol] = "https"

ActionMailer::Base.default_url_options = {
  host: host,
  protocol: "https"
}
