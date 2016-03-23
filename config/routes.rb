Rails.application.routes.draw do
  mount ActionCable.server, at: '/action_cable'

  devise_for :users, controllers: { sessions: 'sessions' }

  resources :users, only: [:index]

  scope '/~:handle', constraints: { handle: User::UNACHORED_HANDLE_MATCHER } do
    get '/', to: 'users#show', as: 'user'
    get '/followers', to: 'users#followers', as: 'user_followers'
    get '/following', to: 'users#following', as: 'user_following'
  end

  resources :locations, only: [:index]

  scope '/@:handle', constraints: { handle: Location::UNACHORED_HANDLE_MATCHER } do
    get '/', to: 'locations#show', as: 'location'
  end

  resources :thoughts, only: [:create, :index]
  resources :follows, only: [:create, :destroy]

  root to: 'thoughts#index'
end
