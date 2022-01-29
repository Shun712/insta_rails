class PostsController < ApplicationController
  # require_loginは、sorceryのメソッド
  before_action :require_login, only: %i[new create edit update destroy]
  def index
    # N + 1問題の対応
    # Rendering posts/index.html.slim within layouts/application
    # Post Load (0.4ms)  SELECT  `posts`.* FROM `posts` ORDER BY `posts`.`created_at` DESC LIMIT 5 OFFSET 0
    # ↳ app/views/posts/index.html.slim:4
    # User Load (0.4ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` IN (10, 9, 8, 7, 6)
    # ↳ app/views/posts/index.html.slim:4
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 11 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:6
    # Rendered collection of posts/_post.html.slim [5 times] (7.4ms)
    # (0.2ms)  SELECT COUNT(*) FROM `posts`
    # ↳ app/views/posts/index.html.slim:5

    # includesメソッドなし
    # Rendering posts/index.html.slim within layouts/application
    # Post Load (1.4ms)  SELECT  `posts`.* FROM `posts` ORDER BY `posts`.`created_at` DESC LIMIT 5 OFFSET 0
    # ↳ app/views/posts/index.html.slim:4
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 10 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:5
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 11 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:6
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 9 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:5
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 8 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:5
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 7 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:5
    # User Load (0.2ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 6 LIMIT 1
    # ↳ app/views/posts/_post.html.slim:5
    @posts = if current_user
               current_user.feed.includes(:user).page(params[:page]).order(created_at: :desc)
             else
               Post.all.includes(:user).page(params[:page]).order(created_at: :desc)
             end
    # scopeに切り出すことを常に意識する。
    @users = User.recent(5)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, success: '投稿しました'
    else
      flash.now[:danger] = '投稿に失敗しました'
      render :new
    end
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to posts_path, success: '投稿を更新しました'
    else
      flash.now[:danger] = '投稿の更新に失敗しました'
      render :edit
    end
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy!
    redirect_to posts_path, success: '投稿を削除しました'
  end

  private

  def post_params
    # 複数画像の投稿なので、カラムに配列で保存できるように設定
    params.require(:post).permit(:body, :images[])
  end
end
