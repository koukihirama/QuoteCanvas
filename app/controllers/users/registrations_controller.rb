class Users::RegistrationsController < Devise::RegistrationsController
  private

  # サインアップ時は従来どおり
  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # アカウント更新時：MVPでは email を更新不可にする（受け取らない）
  def account_update_params
    params.require(:user).permit(:name, :password, :password_confirmation, :current_password)
  end
end
