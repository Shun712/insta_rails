# == Schema Information
#
# Table name: activities
#
#  id           :bigint           not null, primary key
#  action_type  :integer          not null
#  read         :boolean          default("unread"), not null
#  subject_type :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_id   :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_activities_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_activities_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Activity < ApplicationRecord
  # URLヘルパーを使うため導入
  # これでhost("http://instaclone.com/)を提供し、モデルクラス内でヘルパーメソッドを生成できる
  include Rails.application.routes.url_helpers
  # ポリモーフィック関連オプションを使う
  # _ableでなくてもよい
  belongs_to :subject, polymorphic: true
  belongs_to :user

  scope :recent, ->(count) { order(created_at: :desc).limit(count) }
  # enumで1つのカラムに指定した複数個の定数を保存できるようにする
  # DBのaction_typeカラムには、valueの数値が入る
  enum action_type: { commented_to_own_post: 0, liked_to_own_post: 1, followed_me: 2 }
  enum read: { unread: false, read: true }

  # 紐付き先のモデルのshowアクションにredirectさせる場合、polymorphic_pathが使える(今回は使わない)
  # 通知の種類によって分岐する独自メソッドを用意する
  def redirect_path
    # selfが省略されている
    case action_type.to_sym
    when :commented_to_own_post
      # ひも付き先のモデル(post)のshowアクションにredirectする
      post_path(subject.post, anchor: "comment-#{subject.id}")
    when :liked_to_own_post
      post_path(subject.post)
    when :followed_me
      user_path(subject.follower)
    end
  end
end
