Rails.configuration.x.features = ActiveSupport::OrderedOptions.new
Rails.configuration.x.features.password_reset_enabled =
  ActiveModel::Type::Boolean.new.cast(ENV.fetch("PASSWORD_RESET_ENABLED", "false"))
