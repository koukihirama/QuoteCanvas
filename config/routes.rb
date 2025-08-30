Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users
  get "posts/index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "dashboard", to: "dashboard#index"
  root "top#index"  # トップページ
  resources :passages, only: [ :new, :create, :show, :edit, :update, :destroy ]
end
