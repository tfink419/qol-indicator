require 'resque/server'

Rails.application.routes.draw do
  root :to => 'app#index'
  
  # Admin routes
  post 'grocery_stores/upload_csv'
  get 'grocery_stores/upload_csv/status', :to => 'grocery_stores#upload_csv_status_index'
  get 'grocery_stores/upload_csv/status/:id', :to => 'grocery_stores#upload_csv_status_show'
  resources :grocery_stores, :only => [:index, :create, :show, :update, :destroy]
  resources :users, :only => [:index, :create, :show, :update, :destroy]
  post 'build_heatmap', :to => 'build_heatmap#build', :as => 'build_heatmap'
  get 'build_heatmap/status', :to => 'build_heatmap#status_index', :as => 'build_heatmap_status_index'
  get 'build_heatmap/status/:id', :to => 'build_heatmap#status_show', :as => 'build_heatmap_status_show'
  
  resque_web_constraint = lambda do |request|
    request.session[:user_id] and User.find(request.session[:user_id]).admin?
  end
  
  constraints resque_web_constraint do
    mount Resque::Server => '/resque'
  end

  # User routes
  get 'map_preferences', :to => 'map_preferences#show', :as => 'show_map_preferences'
  put 'map_preferences', :to => 'map_preferences#update'
  patch 'map_preferences', :to => 'map_preferences#update', :as => 'update_map_preferences'
  get 'user/self', :to => 'user_self#show', :as => 'show_user_self'
  put 'user/self', :to => 'user_self#update'
  patch 'user/self', :to => 'user_self#update', :as => 'update_user_self'
  get 'map_data', :to => 'map_data#retrieve_map_data', :as => 'retrieve_map_data'

  # Public Routes
  get 'register', :to => 'app#index', :as => 'register'
  get 'login', :to => 'app#index', :as => 'login_page'
  get 'logout', :to => 'login#logout', :as => 'logout'
  post 'login', :to => 'login#attempt_login', :as => 'attempt_login'
  post 'register', :to => 'login#attempt_register', :as => 'attempt_register'
  post 'forgot-password', :to => 'login#forgot_password', :as => 'forgot_password'
  post 'reset-password', :to => 'login#reset_password', :as => 'reset_password'
  get 'reset-password-details', :to => 'login#reset_password_details', :as => 'reset_password_details'
  
  # React routes
  get '/admin/*other', :to => 'app#index'
  get '/*other', :to => 'app#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
