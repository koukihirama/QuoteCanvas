require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  config.action_controller.perform_caching = true

  # Sprockets / assets
  config.assets.compile = false

  # Active Storage（Render だとローカルは短命なので将来的にS3等へ）
  config.active_storage.service = :local

  # HTTPS を強制
  config.force_ssl = true

  # Logging
  config.logger = ActiveSupport::Logger.new(STDOUT).tap { |l| l.formatter = ::Logger::Formatter.new }
  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.active_support.report_deprecations = false

  # I18n
  config.i18n.fallbacks = true

  # DB
  config.active_record.dump_schema_after_migration = false

  # =========================
  # Mailer / URL まわり（★重要）
  # =========================
  host     = ENV.fetch("APP_HOST", "localhost")       # 例: "quotecanvas.onrender.com"
  protocol = ENV.fetch("APP_PROTOCOL", "https")       # "https" or "http"

  # Devise の *_url で使われる既定値
  config.action_mailer.default_url_options = { host:, protocol: }

  # ルーティング層の *_url も揃える
  Rails.application.routes.default_url_options[:host]     = host
  Rails.application.routes.default_url_options[:protocol] = protocol

  # メール内の画像などを絶対URLにしたい場合
  config.action_mailer.asset_host = "#{protocol}://#{host}"

  # 本番ではメールを実際に送る想定に
  config.action_mailer.perform_caching   = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = { from: ENV.fetch("MAILER_FROM", "no-reply@#{host}") }

  # （任意）SMTP を環境変数で設定している場合だけ適用
  if ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV["SMTP_ADDRESS"],
      port:                 Integer(ENV.fetch("SMTP_PORT", "587")),
      user_name:            ENV["SMTP_USERNAME"],
      password:             ENV["SMTP_PASSWORD"],
      domain:               ENV.fetch("SMTP_DOMAIN", host),
      authentication:       ENV.fetch("SMTP_AUTH", "plain"),
      enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(ENV.fetch("SMTP_STARTTLS", "true"))
    }.compact
  end
end
