class Attendance < ApplicationRecord
    belongs_to :user # usersテーブルとの関連付け
    
    def permitted_params
      params.permit attendances: [:attendance_time, :leaving_time, :remarks]
    end
end
