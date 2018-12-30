Rails.application.routes.draw do
  root 'static_pages#home'
  get '/signup',    to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  get '/attendance_edit', to: 'attendances#edit', as: 'edit_attendance'
  post '/attendance_edit', to: 'attendances#edit_all', as: 'edit_attendance_all'
  post '/attendance', to: 'attendances#attendance_update', as: 'attendance'
  post '/leaving', to: 'attendances#leaving_update', as: 'leaving'

  
  get '/basic_info',   to: 'users#edit_basic_info'
  post '/basic_info',   to: 'users#edit_basic_info'
  patch'/basic_info',   to: 'users#edit_basic_info'

resources :attendance
  resources :users do
    get 'attendance_index', to: 'users#attendance_index'
  end
end
