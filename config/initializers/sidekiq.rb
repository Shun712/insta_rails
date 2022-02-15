# SidekiqとRedisが導入されると、設定しておいた処理（今回の場合においてはメール送信）が
# キューとしてRedisサーバーに保存される。

# サーバー側とクライアント側の2種類の設定を追記(Redisの場所を特定する)
# こうすることで、アプリが落ちた時やサーバーが落ちた時の両方に備えられる
# ダッシュボードにアクセスしてからRailsに戻ると、セッションが失効し、ログオフした状態になってしまう。
Sidekiq.configure_server do |config|
  config.redis = {
    url: 'redis://localhost:6379'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: 'redis://localhost:6379'
  }
end