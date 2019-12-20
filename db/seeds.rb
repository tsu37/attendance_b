# ユーザー
User.create!(name:  "管理者1",
            email: "admin1@example.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "管理部",
            user_id: 1000,
            uid: 1000,
            basic_work_time: "8:00",
            designated_work_start_time: "9:00",
            designated_work_end_time: "18:00",
            admin: true,
            activated: true,
            activated_at: Time.zone.now)
             
User.create!(name:  "上長1",
            email: "sperior1@example.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "開発部",
            user_id: 1001,
            uid: 1001,
            basic_work_time: "8:00",
            designated_work_start_time: "9:00",
            designated_work_end_time: "18:00",         
            superior: true,
            activated: true,
            activated_at: Time.zone.now)
            
User.create!(name:  "上長2",
            email: "sperior2@example.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "開発部",
            user_id: 1002,
            uid: 1002,
            basic_work_time: "8:00",
            designated_work_start_time: "9:00",
            designated_work_end_time: "18:00",          
            superior: true,
            activated: true,
            activated_at: Time.zone.now)             

User.create!(name:  "一般1",
            email: "employee1@example.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "開発部",
            user_id: 1003,
            uid: 1003,
            basic_work_time: "8:00",
            designated_work_start_time: "9:00",
            designated_work_end_time: "18:00",
            activated: true,
            activated_at: Time.zone.now)
            
User.create!(name:  "一般2",
            email: "employee2@example.com",
            password: "password",
            password_confirmation: "password",
            affiliation: "開発部",
            user_id: 1004,
            uid: 1004,
            basic_work_time: "8:00",
            designated_work_start_time: "9:00",
            designated_work_end_time: "18:00",        
            activated: true,
            activated_at: Time.zone.now)  
             
# 2.times do |n|
#   name  = Faker::Name.name
#   email = "example-#{n+1}@example.com"
#   password = "password"
#   affiliation = "開発部"
#   user_id = "200#{n+1}"
#   uid　= "200#{n+1}"
#   User.create!(name: name,
#               email: email,
#               password: password,
#               password_confirmation: password,
#               affiliation: "開発部",
#               user_id: user_id,
#               uid: uid,
#               basic_work_time: "8:00",
#               designated_work_start_time: "9:00",
#               designated_work_end_time: "18:00",            
#               activated: true,
#               activated_at: Time.zone.now)
# end