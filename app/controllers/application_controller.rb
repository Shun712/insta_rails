class ApplicationController < ActionController::Base
  # フラッシュメッセージのキーを許可する記述
  # これでBootstrapに対応した success info warning danger 4つのキーが使用できる
  add_flash_types :success, :info, :warning, :danger

  def not_autheticated
    redirect_to login_path, warning: 'ログインしてください'
  end
end
