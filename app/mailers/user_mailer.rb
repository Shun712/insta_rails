class UserMailer < ApplicationMailer
  # メーラーはRailsのコントローラーと似ており、アクションに応じて設定する
  # mailメソッドが呼び出されると、メール本文が記載されているビューが読み込まれる
  # インスタンス変数をビューに渡したいので用意する
  def like_post
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    @post = params[:post]
    mail(to: @user_to.email, subject: "#{@user_from.username}があなたの投稿にいいねしました")
  end

  def comment_post
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    @comment = params[:comment]
    mail(to: @user_to.email, subject: "#{@user_from.username}があなたの投稿にコメントしました")
  end

  def follow
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    mail(to: @user_to.email, subject: "#{@user_from.username}があなたをフォローしました")
  end
end
