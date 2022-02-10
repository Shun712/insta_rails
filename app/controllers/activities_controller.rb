class ActivitiesController < ApplicationController
  before_action :require_login, only: %i[read]

  # read_activity_path(activity)で以下のアクションにリダイレクトされる
  def read
    activity = current_user.activities.find(params[:id])
    # enumにより、activityのreadカラムを確認メソッドとしてtrue falseを返す
    activity.read! if activity.unread?
    # 独自メソッドのredirect_pathでリダイレクト先を分岐している
    redirect_to activity.redirect_path
  end
end
