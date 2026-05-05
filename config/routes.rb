Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  namespace :api do
    mount_devise_token_auth_for "User", at: "auth"
    namespace :v1 do
      resources :tasks
    end

    namespace :v2 do
      resources :tasks

      resources :profile, only: %i[ show update destroy ], controller: :users

      get "news", to: "news#index"
    end

    namespace :v3 do
      resources :tasks do
        member do
          put :restore
          delete :hard_destroy
        end
        collection do
          get :trashed
        end
      end
    end
  end
end
