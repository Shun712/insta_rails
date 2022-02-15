require 'sidekiq/web'

Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
    mount Sidekiq::Web, at: '/sidekiq'
  end
  root 'posts#index'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  resources :users, only: %i[index new create show]
  resources :posts, shallow: true do
    # URLにpostのidはつかない
    # リソース全体(posts)に対して、アクションを追加(生成されるURL:/posts/search)
    collection do
      get :search
    end
    resources :comments
  end
  # memberオプションで、activities/:idのurlが生成される
  # activities/:id/readのurl以外使用したくないので、onlyで絞る
  resources :activities, only: [] do
    # DHH流で、readsコントローラーを作成すると以下のようになる
    # resource :read, only: %i[create]
    patch :read, on: :member
  end
  # ネストさせていない。
  resources :likes, only: %i[create destroy]
  resources :relationships, only: %i[create destroy]
  namespace :mypage do
    resource :account, only: %i[edit update]
    resources :activities, only: %i[index]
  end
end
