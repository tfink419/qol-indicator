Rails.application.routes.draw do
  root :to => 'map#index'
  get '/', :to => 'map#index', :as => 'map_index'
  get 'admin/index'
  get 'register', :to => 'login#login', :as => 'register'
  get 'login', :to => 'login#login', :as => 'login_page'
  get 'logout', :to => 'login#logout', :as => 'logout'
  post 'login', :to => 'login#attempt_login', :as => 'attempt_login'
  post 'register', :to => 'login#attempt_register', :as => 'attempt_register'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
