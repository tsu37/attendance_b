# ユーザー
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "管理部",
             user_id: 1000,
             uid: 1000,
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)
             
User.create!(name:  "上長",
             email: "jocho@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "開発部",
             user_id: 1001,
             uid: 1001,
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)
# 99.times do |n|
#   name  = Faker::Name.name
#   email = "example-#{n+1}@railstutorial.org"
#   password = "password"
#   affiliation = "開発部"
#   user_id = "000-#{n+1}"
#   uid　= "100-#{n+1}"
#   User.create!(name:  name,
#               email: email,
#               password:              password,
#               password_confirmation: password,
#               activated: true,
#               activated_at: Time.zone.now)
# end