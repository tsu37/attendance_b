module AttendancesHelper
    def attendances_check  # 勤怠一括編集アクション内の入力チェック
        # error_count = 0
        # params[:attendance].each do |id, item|
        #   attendance = Attendances.find(id)
        #   #当日以降の編集はadminユーザのみ
        #   if item["attendance_time"].blank? && item["attendance_time"].blank?
        #   # 両方空はそもそも入力していないので、カウント外
        #   elsif (attendance.day > Date.current) && !current_user.admin?
        #     error_count += 1
        #   elsif item["attendance_time"].blank? || item["attendance_time"].blank?
        #     error_count += 1
        #   elsif item["attendance_time"].to_s > item["leaving_time"].to_s
        #     error_count += 1
        #   end
        # end
        return error_count # 入力エラー件数を返す
    end
end
