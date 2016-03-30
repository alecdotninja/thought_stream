Rails.application.routes.draw do
  mount ActionCable.server, at: '/action_cable'

  devise_for :users, controllers: { sessions: 'sessions' }

  resources :users, only: [:index]

  scope '/~:handle', constraints: { handle: User::UNACHORED_HANDLE_MATCHER }, as: 'user' do
    get '/', to: 'users#show'
    get '/followers', to: 'users#followers', as: 'followers'
    get '/following', to: 'users#following', as: 'following'

    resource :hip_check, only: [:new, :create]
  end

  resources :locations, only: [:index]

  get '/@:handle', to: 'locations#show', constraints: { handle: Location::UNACHORED_HANDLE_MATCHER }, as: 'location'

  resources :thoughts, only: [:create, :index]
  resources :follows, only: [:create, :destroy]

  root to: 'thoughts#index'
end
