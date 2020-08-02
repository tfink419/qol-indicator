require 'sidekiq/web'

Rails.application.routes.draw do
  root :to => 'app#index'
  
  # Admin routes
  scope '/api/' do
    post 'admin/grocery_stores/start_upload'
    get 'admin/grocery_stores/upload/status', :to => 'admin/grocery_stores#upload_status_index'
    get 'admin/grocery_stores/upload/status/:id', :to => 'admin/grocery_stores#upload_status_show'
    resources 'admin/grocery_stores', :only => [:index, :create, :show, :update, :destroy], :as => 'admin_grocery_stores'
    resources 'admin/users', :only => [:index, :create, :show, :update, :destroy], :as => 'admin_users'
    resources 'admin/api_keys', :only => [:index, :create, :show, :destroy], :as => 'admin_api_keys'
    post 'admin/census_tracts/import', :to => 'admin/census_tracts#import', :as => 'admin_census_tracts_import'
    post 'admin/build_quality_map', :to => 'admin/build_quality_map#build', :as => 'admin_build_quality_map'
    get 'admin/build_quality_map/status', :to => 'admin/build_quality_map#status_index', :as => 'admin_build_quality_map_status_index'
    get 'admin/build_quality_map/status/:id', :to => 'admin/build_quality_map#status_show', :as => 'admin_build_quality_map_status_show'
  end
  sidekiq_web_constraint = lambda do |request|
    request.session[:user_id] and User.find(request.session[:user_id]).admin?
  end
  
  constraints sidekiq_web_constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  # User routes
  resources 'grocery_stores', :only => [:show], :as => 'grocery_stores'
  get 'map_preferences', :to => 'map_preferences#show', :as => 'show_map_preferences'
  put 'map_preferences', :to => 'map_preferences#update'
  patch 'map_preferences', :to => 'map_preferences#update', :as => 'update_map_preferences'
  get 'user/self', :to => 'user_self#show', :as => 'show_user_self'
  put 'user/self', :to => 'user_self#update'
  patch 'user/self', :to => 'user_self#update', :as => 'update_user_self'
  get 'map_data/quality_map', :to => 'map_data#get_quality_map_image', :as => 'map_data_get_quality_map_image'
  get 'map_data/grocery_stores', :to => 'map_data#get_grocery_stores', :as => 'map_data_get_grocery_stores'
  get 'map_data/point', :to => 'map_data#get_point_data', :as => 'map_data_get_point_data'

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
