require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  config.action_controller.perform_caching = true

  # Sprockets / assets
  config.assets.compile = false

  # Active Storage（将来的に S3 などへ移行を検討）
  config.active_storage.service = :local

  # HTTPS を強制（ヘルスチェック /up は除外）
  config.force_ssl = true
  config.ssl_options = {
    redirect: { exclude: ->(req) { req.path == "/up" } }
  }

  # Logging（TaggedLogging で request_id などのタグを確実に出力）
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.active_support.report_deprecations = false

  # I18n
  config.i18n.fallbacks = true

  # DB
  config.active_record.dump_schema_after_migration = false

  # =========================
  # Mailer / URL まわり
  # =========================
  host     = ENV.fetch("APP_HOST", "localhost")   # 例: "quotecanvas.onrender.com"
  protocol = ENV.fetch("APP_PROTOCOL", "https")   # "https" or "http"

  # Devise の *_url で使われる既定値
  config.action_mailer.default_url_options = { host:, protocol: }

  # ルーティング層の *_url も揃える
  Rails.application.routes.default_url_options[:host]     = host
  Rails.application.routes.default_url_options[:protocol] = protocol

  # メール内の画像などを絶対URLで指す場合に利用
  config.action_mailer.asset_host = "#{protocol}://#{host}"

  # メール配送
  config.action_mailer.perform_caching         = false
  config.action_mailer.perform_deliveries      = true
  config.action_mailer.raise_delivery_errors   = true
  config.action_mailer.default_options         = { from: ENV.fetch("MAILER_FROM", "no-reply@#{host}") }

  if ENV["SMTP_ADDRESS"].present?
    # SMTP を設定したら自動で有効化
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
  else
    # SMTP 未設定時は “失敗しないが送らない” セーフティ
    # （プロバイダ設定後は上のブロックが使われます）
    config.action_mailer.delivery_method = :test
  end
end
