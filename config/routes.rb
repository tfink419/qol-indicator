Rails.application.routes.draw do
  root :to => 'app#index'

  post 'grocery_stores/upload_csv'
  resources :grocery_stores, :only => [:index, :create, :show, :update, :destroy]
  resources :users, :only => [:index, :create, :show, :update, :destroy]

  get 'register', :to => 'app#index', :as => 'register'
  get 'login', :to => 'app#index', :as => 'login_page'
  get 'logout', :to => 'login#logout', :as => 'logout'
  post 'login', :to => 'login#attempt_login', :as => 'attempt_login'
  post 'register', :to => 'login#attempt_register', :as => 'attempt_register'
  
  get '/admin/*other', :to => 'app#index'
  get '/*other', :to => 'app#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
