class RelationshipsController < ApplicationController
  before_action :require_login, only: %i[create destroy]

  def create
    # ビューのクエリパラメータから:followed_idを取得
    @user = User.find(params[:followed_id])
    UserMailer.with(user_from: current_user, user_to: @user).follow.deliver_now if current_user.follow(@user)
  end

  def destroy
    # Relationshipはfollowedとfollowerが一意なのでパラメーターからidを取得
    # followedは、belongs_toでfollowedを関連付けしているので、.followedでユーザーを取ってこれる。
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
  end
end
