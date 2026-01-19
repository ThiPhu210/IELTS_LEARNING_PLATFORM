# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.headers = {
    "cache-control" => "public, max-age=#{1.year.to_i}"
  }

  config.active_storage.service = :amazon
  config.assume_ssl = true
  config.force_ssl = true
  config.session_store :cookie_store,
    key: "_ielts_session",
    secure: true,
    same_site: :lax


  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.active_job.queue_adapter = :sidekiq

  # ActionMailer
  config.action_mailer.default_url_options = {
    host: "d34ute7tylgmox.cloudfront.net",
    protocol: "https"
  }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.logger = Logger.new(STDOUT)
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "gmail.com",
    user_name: ENV["GMAIL_USERNAME"],
    password: ENV["GMAIL_APP_PASSWORD"],
    authentication: "plain",
    enable_starttls_auto: true
  }

  config.cache_classes = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # Hosts
  config.hosts << "184.72.213.33"
  config.hosts << "d34ute7tylgmox.cloudfront.net"
  config.hosts << "ec2-184-72-213-33.compute-1.amazonaws.com"

  config.action_dispatch.trusted_proxies = [ IPAddr.new("0.0.0.0/0") ]
  config.action_controller.forgery_protection_origin_check = true
end
