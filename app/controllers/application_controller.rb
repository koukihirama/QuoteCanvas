class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # sign_up と account_update に name を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  #  ログイン後の遷移先
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  #  ログアウト後の遷移先
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_update_path_for(resource)
    profile_path
  end
end
