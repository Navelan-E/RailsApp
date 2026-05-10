Rails.application.routes.draw do
  use_doorkeeper
  devise_for :admin_users
  devise_for :mechanics
  devise_for :customers
  ActiveAdmin.routes(self)
  get 'profile/show'
  get 'profile/edit'
  get 'profile/show'
  
  get 'tags/index'
  get 'home/index'
  get 'reviews/index'
  get 'reviews/show'
  get 'reviews/new'
  get 'reviews/edit'
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
  get "/tags", to: "tags#index"
  get "/customer/signup", to: "customers/registrations#new"
  get "/mechanic/signup", to: "mechanics/registrations#new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :mechanics do
    member do
      patch :disable
      patch :unlock
    end
  end
  resources :vehicles
  resources :customers
  resources :records
  resources :summaries
  resources :parts
  resources :reviews
  resources :customers do
    member do
      patch :disable
      patch :unlock
    end
  end

  root to: "home#index"

  namespace :api do
    namespace :v1 do
      resources :mechanics do
        member do
          patch :disable
          patch :unlock
        end
        collection do
          get :available
        end
      end
      resources :customers do
    member do
        patch :disable
        patch :unlock
      end
    end
      resources :records
      resources :parts
      resources :reviews
      resources :vehicles
      resources :summaries
      resources :tags
    end
  end
end
