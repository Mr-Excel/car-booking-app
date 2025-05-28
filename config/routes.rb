Rails.application.routes.draw do
  # Root route
  root "home#index"
  
  # Tenant routes
  resources :tenants, only: [:new, :create]
  
  # Session routes
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # User routes
  resources :users
  
  # Guest user routes
  resources :guest_users, only: [:new, :create]
  
  # Booking routes
  resources :bookings do
    member do
      patch :cancel
    end
  end
  
  # Payment routes
  resources :payments, only: [:new, :create, :show]
  
  # Stripe webhook
  post 'stripe_webhook', to: 'payments#webhook'
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :bookings, only: [:create, :show]
      resources :payments, only: [:create]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
