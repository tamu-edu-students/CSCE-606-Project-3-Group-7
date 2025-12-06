Rails.application.routes.draw do
  # OAuth routes - handled by ApplicationController
  match "/auth/:provider/callback", to: "application#oauth_callback", via: [ :get, :post ]
  get "/auth/failure", to: "application#oauth_failure"
  post "/logout", to: "application#logout"
  get  "/logout", to: "application#logout"
  get "/auth/:provider", to: "omniauth#passthru"
  get "pages/home"
  root "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Chat UI
  get "/chat", to: "chats#index", as: :chat

  # Messages - index handled by ChatsController, but create/destroy here
  resources :messages, only: [ :create, :destroy ]

  # Admin view — optional: all messages
  get "/admin/messages", to: "admin/messages#index", as: :admin_messages
  get "/admin/users", to: "admin/users#index", as: :admin_users
end
