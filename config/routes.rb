Rails.application.routes.draw do
  get "thought_logs/new"
  get "dashboard/index"
  devise_for :users
  get "posts/index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "dashboard", to: "dashboard#index"
  root "top#index"
  get "profile", to: "users#show", as: :profile

  resources :passages, only: [ :new, :create, :show, :edit, :update, :destroy ] do
    resources :thought_logs, only: [ :new, :create ]
  end
end
