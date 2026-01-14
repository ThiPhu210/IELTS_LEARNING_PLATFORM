if Rails.env.production?
  Rails.application.config.action_mailer.default_url_options = {
    host: "d34ute7tylgmox.cloudfront.net",
    protocol: "https"
  }
end
