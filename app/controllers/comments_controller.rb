class CommentsController < ApplicationController
  before_action :require_login, only: %i[create update destroy]
  # 共通化
  before_action :set_comment, only: %i[edit update destroy]

  def create
    @comment = current_user.comments.build(comment_params)
    # コメントされたら、メール送信処理される。
    # コールバックで送信しないようにする(https://techracho.bpsinc.jp/hachi8833/2019_09_12/76762)
    # withに渡されるキーの値は、メイラーアクションでは単なるparamsになる。
    # メイラーアクションで`params[:user_from]`や`params[:user_to]`や`params[:comment]`を使えるようになる
    # deliver_laterは非同期処理にする送信
    UserMailer.with(user_from: current_user, user_to: @comment.post.user, comment: @comment).comment_post.deliver_later if @comment.save
  end

  def edit; end

  def update
    @comment.update(comment_update_params)
  end

  def destroy
    @comment.destroy!
  end

  private

  def set_comment
    # params[:id]はcommentのid(postのidがなくても特定できる)
    @comment = current_user.comments.find(params[:id])
  end

  def comment_params
    # commentをcreateする場合、postへの紐付けが必要になる。
    # userへの紐付けはcurrent_userによって、(user_id: current_user.id)となっている。
    params.require(:comment).permit(:body).merge(post_id: params[:post_id])
  end

  def comment_update_params
    params.require(:comment).permit(:body)
  end
end
