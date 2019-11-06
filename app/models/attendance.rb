class Attendance < ApplicationRecord
  belongs_to :user # usersテーブルとの関連付け
  # 残業申請状態（0:無 1:申請中 2:承認 3:否認）
  enum application_state: { nothing: 0, applying: 1, approval: 2, denial:3 }
  # 勤怠編集申請状態（0:無 1:申請中 2:承認 3:否認）
  enum application_edit_state: { nothing0: 0, applying1: 1, approval2: 2, denial3:3 }
  # validates :scheduled_end_hour, presence: true

  
  
  def permitted_params
    params.permit attendances: [:attendance_time, :leaving_time, :remarks]
  end
  
  class << self
    def localed_application_statuses
      application_states.keys.map do |s|
        [ApplicationController.helpers.t("application_status.article.#{s}"), s]
      end
    end
  end
  
  class << self
    def localed_application_edit_statuses
      application_edit_states.keys.map do |s|
        [ApplicationController.helpers.t("application_edit_states.article.#{s}"), s]
      end
    end
  end
end
