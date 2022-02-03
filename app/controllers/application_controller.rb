class ApplicationController < ActionController::Base
  # フラッシュメッセージのキーを許可する記述
  # これでBootstrapに対応した success info warning danger 4つのキーが使用できる
  add_flash_types :success, :info, :warning, :danger
  before_action :set_search_posts_form

  private

  def not_authenticated
    redirect_to login_path, warning: 'ログインしてください'
  end

  # ヘッダー部分(=共通部分)に検索フォームを置くので、ApplicationControllerに実装
  def set_search_posts_form
    @search_form = SearchPostsForm.new(search_post_params)
  end

  def search_post_params
    params.fetch(:q, {}).permit(:body, :comment_body, :username)
  end
end
