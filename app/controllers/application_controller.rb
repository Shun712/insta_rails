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
  # 検索ワードをインスタンス変数に代入
  def set_search_posts_form
    @search_form = SearchPostsForm.new(search_post_params)
    # [3] pry(#<PostsController>)> search_post_params
    # => <ActionController::Parameters {"body"=>"it", "comment_body"=>"", "username"=>""} permitted: true>
  end

  def search_post_params
    # paramsはフォームなどによって送られてきた情報（パラメータ）を取得する
    # fetchメソッドはハッシュから指定したキーのバリュ−を取り出す。
    # params.fetch(:q, {})は、params[:q]が空の場合はnil({})を返し、あればparams[:q]を返す
    params.fetch(:q, {}).permit(:body, :comment_body, :username)
  end
end
