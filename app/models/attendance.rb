class Attendance < ApplicationRecord
    belongs_to :user # usersテーブルとの関連付け
end
