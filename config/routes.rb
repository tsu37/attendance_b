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

  # ユーザ関係
  resources :users do
    collection { post :import }
  end
  
  # CSVインポート
  post '/csv_import' , to: 'users#csv_import', as: 'csv_import'
  
  # 勤務時間のCSVエクスポート
  # get '/att_csv_export' , to: 'attendance#att_csv_export', as: 'att_csv_export'
  # post '/att_csv_export' , to: 'attendance#att_csv_export', as: 'att_csv_export'
  
  # CSV出力用
  get '/user_att_export', to: 'users#att_export', as: 'att_export'
  
  # 出勤中社員の一覧
  get '/user_attendance_list', to: 'users#attendance_list', as: 'user_attendance_list'
  
end
