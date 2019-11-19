Rails.application.routes.draw do
  root 'static_pages#home'
  get '/signup',    to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  get '/attendance_edit', to: 'attendances#edit', as: 'edit_attendance'
  post '/attendance', to: 'attendances#update_all', as: 'update_all_attendance'
  post '/attendance', to: 'attendances#attendance_update', as: 'attendance'
  post '/leaving', to: 'attendances#leaving_update', as: 'leaving'
  # patch '/attendance', to: 'attendances_#update_attendance', as: 'update_attendance'
  post '/attendance/applied', to: 'attendance#update_applied_attendance', as: 'update_applied_attendance'

  # 残業申請関係
  get '/attendance/overtime', to: 'attendances#edit_overtime', as: 'edit_overtime_attendance'
  post '/attendance/overtime', to: 'attendances#overtime_application', as: 'overtime_application'
  post '/attendance/one_overtime', to: 'attendances#one_overtime_application', as: 'one_overtime_application'
  
  # 1ヵ月分勤怠の確認申請関係
  post '/users/onemonth', to: 'users#onemonth_application', as: 'onemonth_application'
  post '/attendance/update_onemonth', to: 'attendance#update_onemonth_applied_attendance', as: 'update_onemonth_applied_attendance'
  
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
  post '/import' , to: 'users#import', as: 'import'
  
  # CSV出力用
  get '/user_att_export', to: 'users#att_export', as: 'att_export'
  
  # 出勤中社員の一覧
  get '/user_attendance_list', to: 'users#attendance_list', as: 'user_attendance_list'
  
  # 拠点情報関係
  resources :base_points
  post '/base_point/create',  to: 'base_points#create', as: 'base_point_create'
  
  # 上長の勤怠確認ページ
  get '/show_confirm', to: 'users#show', as: 'show'
  
end
