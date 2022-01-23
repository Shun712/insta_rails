puts 'Start inserting seed "posts" ...'
User.limit(10).each do |user|
  # Lorem Picsumというgemを使用。画像を返してくれる便利サービス。
  # remote_images_urls: というカラムは、「https://~~~.jpg」のような外部から取ってきた画像を設定する。
  # 「remote_カラム名_url」とすれば使える。
  # https://github.com/carrierwaveuploader/carrierwave#uploading-files-from-a-remote-location
  post = user.posts.create(body: Faker::Hacker.say_something_smart, remote_images_urls: %w[https://picsum.photos/350/350/?random https://picsum.photos/350/350/?random])
  puts "post#{post.id} has created!"
end