# このファイル名と一致するアクション実行時に
# このファイル内の処理が呼び出される
require 'csv'
require 'nkf'

# nullチェックメソッド
# nullなら空文字を返す
def CheckNull(param)
  if !param.nil?
    return param
  else
    ""
  end
end

csv_str = CSV.generate do |csv|
  # ユーザ情報のヘッダー
  csv << ["#{@first_day.strftime("%Y年%m月")}　時間管理表"]
  csv << ["名前", @user.name, "所属", @user.affiliation, "コード", @user.user_id, "出勤日数", "#{@attendance_days}日"]
  # 改行
  csv << [""]
  
  # 勤怠情報のヘッダー
  csv_column_names = %w(日付 曜日 出社時間 退社時間 在社時間 備考 指示者)
  csv << csv_column_names
  @attendances.each do |attendance|
  
    # 出社時間
    !attendance.attendance_time.nil? ? attendance_time = attendance.attendance_time.strftime("%H:%M") : attendance_time = "";
    # 退社時間
    !attendance.leaving_time.nil? ? leaving_time = attendance.leaving_time.strftime("%H:%M") : leaving_time = "";
    # 在社時間
    !attendance.attendance_time.nil? && !attendance.leaving_time.nil? ? work_sum = format("%.2f", (attendance.leaving_time - attendance.attendance_time)/3600) : work_sum = "";
    
    csv_column_values = [
      attendance.day.strftime("%m/%d"),
      @day_of_week[attendance.day.wday],
      attendance_time,
      leaving_time,
      work_sum,
      attendance.remarks,
      attendance.instructor
    ]
    csv << csv_column_values
  end
  
  # 改行
  csv << [""]
  # 基本時間の合計
  basic_work_sum = 0
  if !@user.basic_work_hour.blank? && !@attendance_days.blank?
    basic_work_sum = format("%.2f", @attendance_days*(((@user.basic_work_hour.hour*60.0) + @user.basic_work_hour.min)/60))
  else
    basic_work_sum = "エラー"
  end
  csv << ["基本時間の合計", basic_work_sum]
  # 改行
  csv << [""]
  # 在社時間の合計
  csv << ["在社時間の合計", @work_sum]
  # 改行
  csv << [""]
  # 所属長承認欄 @TODO:承認状態に応じて『未』『承』を表示する
  csv << ["所属長承認:"]
end

# 文字化けを防止するためにNKFで文字コード変換
NKF::nkf('--sjis -Lw', csv_str)
