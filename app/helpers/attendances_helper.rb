module AttendancesHelper
  def attendances_check  # 勤怠一括編集アクション内の入力チェック
    error_count = 0
    params[:attendances].each do |id, item|
      attendance = Attendance.find(id)
      #出社時間と退社時間の両方の存在を確認
      if item["leaving_time"].blank? && item["attendance_time"].blank?
      #当日以降の編集はadminユーザのみ
      elsif item["leaving_time"].blank? || item["attendance_time"].blank?
        error_count += 1
      elsif (attendance.day > Date.current)
        error_count += 1
      #出社時間 > 退社時間ではないか
      elsif item["attendance_time"].to_s > item["leaving_time"].to_s
        error_count += 1
      end
    end
    return error_count # 入力エラー件数を返す
  end
end
