Rails.application.routes.draw do
  devise_for :users

  # ヘルス/PWA
  get "up"                => "rails/health#show",  as: :rails_health_check
  get "service-worker"    => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"          => "rails/pwa#manifest", as: :pwa_manifest

  # 画面
  root "top#index"
  get "dashboard", to: "dashboard#index"
  get "profile",   to: "users#show", as: :profile

  # 書籍ルックアップ（今回の主役）
  get "books/lookup", to: "books#lookup"

  # passages
  resources :passages, only: [:new, :create, :show, :edit, :update, :destroy] do
    resources :thought_logs, only: [:new, :create]
    resource  :customization, only: [:new, :create, :edit, :update],
              controller: "passage_customizations"
  end

  # （任意）API用エンドポイントも残すなら
  namespace :api do
    resources :books, only: [:index]  # /api/books?isbn=... or &title=...
  end
end