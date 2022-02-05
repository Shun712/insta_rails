# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  avatar           :string(255)
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
  # foreign_keyで定義することで、親モデル(follower)と関連付けられる。
  # foreign_keyでフォローする側(follower)からフォロー関係を関連付けている。
  # この段階では、自分が誰をフォローしているかまでしかわからない(active_relationshipsテーブルのレコードを取得しているにすぎない)。
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  # これでようやくフォローされる側(followed)のユーザーを中間テーブル(active_relationships)を介して取得することを「following」と定義
  has_many :following, through: :active_relationships, source: :followed
  # foreign_keyで定義することで、親モデル(followed)と関連付けられる。
  # フォローされる側(followed)からフォロー関係を関連付けている。
  # この段階では、自分が誰からフォローされているかまでしかわからない(passive_relationshipsテーブルのレコードを取得しているにすぎない)。
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  # フォローされる側(followed)のユーザーを中間テーブル(active_relationships)を介して取得することを「following」と定義
  has_many :following, through: :active_relationships, source: :followed
  # フォローする側(follower)のユーザーを中間テーブル(passive_relationships)を介して取得することを「followers」と定義
  has_many :followers, through: :passive_relationships, source: :follower
  # ユーザーがいいねしたツイートを直接アソシエーションで取得することができるようカラムを設定
  # [【初心者向け】丁寧すぎるRails『アソシエーション』チュートリアル【幾ら何でも】【完璧にわかる - qiita](https://qiita.com/kazukimatsumoto/items/14bdff681ec5ddac26d1#has-many-through)
  has_many :like_posts, through: :likes, source: :post

  # ->{ }による方法(lambdaによって作成されたProcオブジェクトと同じ性質をもつオブジェクトを作成する。）
  scope :recent, -> (count) { order(created_at: :desc).limit(count) }

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

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    following.destroy(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def feed
    # 自分と自分がフォローしているユーザーのidを取得する
    # following_idsメソッドは、そのコレクションに含まれるオブジェクトのidを配列にしたものを返す
    # Post.where(user_id: self.following_ids.<<(self.id))と同じ
    # つまり、Post.where(user_id: current_user.following_ids << current_user.id)
    # モデルで書くインスタンスメソッドは、 self が省略される
    # <<もメソッドであり、idは引数
    # [問題です！ ①と②が同じだって分かりますか？（クラス・インスタンス・メソッド・引数を実践で理解しよう！） - qiita](https://qiita.com/miketa_webprgr/items/361d339d2739792457ab)
    # rubyではメソッドの中で、そのメソッドが属しているインスタンスをselfで参照でき、省略可能
    # メソッド中でレシーバを省略してメソッド呼び出しを行った場合は、暗黙的にselfがレシーバになる
    # ただし、セッターメソッドを呼ぶ時はselfを省略出来ない。
    # [rubyでselfを省略できる時、できない時 - qiita](https://qiita.com/akira-hamada/items/4132d2fda7e420073ab7)
    Post.where(user_id: following_ids << id)
  end
end
