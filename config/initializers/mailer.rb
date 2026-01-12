if Rails.env.production?
  Rails.application.config.action_mailer.default_url_options = {
    host: "ielts-learning-platform.duckdns.org",
    protocol: "https"
  }
end

