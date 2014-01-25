require 'sidekiq/web'
require 'admin_constraint'

TeemosCasino::Application.routes.draw do
  root 'pages#index'

  # Beta landing roadblock
  get :landing, to: 'pages#landing'

  namespace :api, defaults: {format: :json} do
    resources :game_events, only: [] do
      collection do
        post :start
        post :end
      end
    end

    resource :user, only: [:show] do
      get :logout, to: :destroy
    end

    resource :bet, only: [:show, :create]

    resource :bettors, only: [:show]
  end

  # Authentication
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  mount Sidekiq::Web => '/debug/sidekiq', constraints: AdminConstraint.new
end
