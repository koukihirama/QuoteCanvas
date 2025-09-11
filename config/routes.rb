Rails.application.routes.draw do
  get "static/guide"
  devise_for :users

  # ヘルス/PWA
  get "up"             => "rails/health#show",  as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"       => "rails/pwa#manifest", as: :pwa_manifest

  # 画面
  root "top#index"
  get "dashboard", to: "dashboard#index"
  get "profile",   to: "users#show", as: :profile

  get "books/lookup", to: "books#lookup"
  get "/guide", to: "static#guide", as: :guide
  patch "users/hide_guide", to: "users#hide_guide"

  # 書籍検索フォーム画面
  resources :book_infos, only: [] do
    collection do
      get :search
    end
  end

  # API (残しておく)
  namespace :api do
    resources :books, only: [ :index ]
  end

  # passages
  resources :passages, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resources :thought_logs, only: [ :new, :create ]
    resource  :customization, only: [ :new, :create, :edit, :update ],
              controller: "passage_customizations"
  end
end
