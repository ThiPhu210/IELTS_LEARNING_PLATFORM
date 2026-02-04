if Rails.env.production?
  Rails.application.config.action_mailer.default_url_options = {
    host: "https://resigned-unincreased-agnus.ngrok-free.dev",
    protocol: "https"
  }
end
