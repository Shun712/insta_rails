require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module InstaRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators.system_tests = nil

    config.generators do |g|
      g.skip_routes true
      g.assets false
      g.helper false
      g.test_framework false # testファイルを生成しない
    end

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb.yml}').to_s]

    # ActiveJobのアダプターとしてSidekiqを利用することを宣言(キューイングバックエンドを設定)
    # バックグラウンド(ジョブ管理)でキューを処理するサーバーとしてSidekiqを指定
    config.active_job.queue_adapter = :sidekiq
  end
end
