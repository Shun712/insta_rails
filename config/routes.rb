Rails.application.routes.draw do
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
  resources :activities, only: [] do
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
