# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  crypted_password :string(255)
#  email            :string(255)      not null
#  salt             :string(255)
#  username         :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :username, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  # ユーザーがいいねしたツイートを直接アソシエーションで取得することができるようカラムを設定
  # [【初心者向け】丁寧すぎるRails『アソシエーション』チュートリアル【幾ら何でも】【完璧にわかる - qiita](https://qiita.com/kazukimatsumoto/items/14bdff681ec5ddac26d1#has-many-through)
  has_many :like_posts, through: :likes, source: :post

  # 例えば、current_user.id == post.user_idで判定する。
  def own?(object)
    id == object.user_id
  end

  # 「いいね」したpostをlike_postsへpush
  def like(post)
    like_posts << post
  end

  # 「いいね」したpostをlike_postsから削除
  def unlike(post)
    # deleteよりdestroyの方がコールバックが動くから安全
    like_posts.destroy(post)
  end

  # userがすでにそのpostに「いいね！」しているかを判別
  def like?(post)
    like_posts.include?(post)
  end
end
