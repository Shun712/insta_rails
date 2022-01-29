class UserSessionsController < ApplicationController
  before_action :check_logged_in, only: %i[new create]

  # 改行の代わりにセミコロン(;)を使用することも可能
  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to posts_path, success: 'ログインしました'
    else
      flash.now[:danger] = 'ログインに失敗しました'
      render :new
    end
  end

  def destroy
    logout
    redirect_to login_path, success: 'ログアウトしました'
  end

  private

  def check_logged_in
    redirect_to posts_path if current_user.present?
  end
end
