Rails.application.routes.draw do
  root :to => 'app#index'
  resources :users, :only => [:index, :create, :update, :destroy] do
    member do
      get :delete
    end
  end
  get '/*other', :to => 'app#index'
  get '/admin/*other', :to => 'app#index'

  get 'register', :to => 'app#index', :as => 'register'
  get 'login', :to => 'app#index', :as => 'login_page'
  get 'logout', :to => 'app#index', :as => 'logout'
  post 'login', :to => 'login#attempt_login', :as => 'attempt_login'
  post 'register', :to => 'login#attempt_register', :as => 'attempt_register'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
