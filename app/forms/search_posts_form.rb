class SearchPostsForm
  # includeすることにより、ActiveModel::ModelとActiveModel::Attributesが使える
  # includeしているものは「モジュール」という
  # これにより、モデルっぽいものが作れる
  include ActiveModel::Model
  include ActiveModel::Attributes

  # ActiveRecord(モデル)のカラムのような属性を加えられる
  attribute :body, :string
  attribute :comment_body, :string
  attribute :username, :string

  def search
    scope = Post.distinct
    # mapはブロック内の処理をした結果を配列として返す
    # splited_bodies.map｛ |splited_body| scope.body_contain(splited_body) }
    #  ↓
    # ["電車", "卵", "携帯"].map ｛ |splited_body| scope.body_contain(splited_body) }
    #  ↓
    # [scope.body_contain("電車"), scope.body_contain("卵"), scope.body_contain("携帯")]
    #  ↓
    # これがActiveRecord::Relationの形になっている(配列と形は同じだが、厳密には配列ではない)。例えば、[[a, b, c], [d, e], [f]]。
    #  ↓
    # splited_bodies.map { |splited_body| scope.body_contain(splited_body) }.inject { |result, scp| result.or(scp) }
    #  ↓
    # [scope.body_contain("電車"), scope.body_contain("卵"), scope.body_contain("携帯")].inject { |result, scp| result.or(scp) }
    #  ↓
    # scope.body_contain("電車").or(scope.body_contain("卵")).or.(scope.body_contain("携帯"))
    #  ↓
    # injectメソッドで[a ,b, c, d, e, f]の形にする。
    scope = splited_bodies.map { |splited_body| scope.body_contain(splited_body) }.inject { |result, scp| result.or(scp) } if body.present?
    # if comment_body.present?には、self(@search_form)がSearchPostsFormのインスタンスなので省略されている
    scope = scope.comment_body_contain(comment_body) if comment_body.present?
    scope = scope.username_contain(username) if username.present?
    scope
  end

  private

  def splited_bodies
    # " abc def ghi "はsplitメソッドで"abc def ghi"となり、文字列先頭と最後の空白を削除
    # (/[[:blank]]+/)は、空白が1回以上のところで文字列を分割し配列で返す
    body.strip.split(/[[:blank]]+/)
  end
end
