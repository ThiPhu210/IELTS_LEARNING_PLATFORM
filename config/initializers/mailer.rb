Rails.application.routes.default_url_options = {
  host: ENV.fetch("MAILER_HOST", "ielts-learning-platform.duckdns.org"),
  port: ENV.fetch("MAILER_PORT", 3000)
}

Rails.application.config.action_mailer.default_url_options = {
  host: ENV.fetch("MAILER_HOST", "ielts-learning-platform.duckdns.org"),
  port: ENV.fetch("MAILER_PORT", 3000)
}
