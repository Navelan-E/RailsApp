Rails.application.routes.draw do
  get 'home/index'
  get 'reviews/index'
  get 'reviews/show'
  get 'reviews/new'
  get 'reviews/edit'
  get 'summaries/index'
  get 'summaries/show'
  get 'summaries/edit'
  get 'summaries/index'
  get 'summaries/show'
  get 'summaries/new'
  get 'summaries/edit'
  get 'parts/index'
  get 'parts/show'
  get 'parts/new'
  get 'parts/edit'
  get 'vehicles/index'
  get 'vehicles/show'
  get 'vehicles/new'
  get 'vehicles/edit'
  get 'records/index'
  get 'records/show'
  get 'records/new'
  get 'records/edit'
  get 'customers/index'
  get 'customers/show'
  get 'customers/new'
  get 'customers/edit'
  get 'mechanics/index'
  get 'mechanics/show'
  get 'mechanics/new'
  get 'mechanics/edit'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :mechanics
  resources :vehicles
  resources :customers
  resources :records
  resources :summaries
  resources :parts
  resources :reviews, only: [:new, :create]
end
