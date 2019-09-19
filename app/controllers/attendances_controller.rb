class AttendancesController < ApplicationController
  # 出勤・退社ボタン押下
  def attendance_update
    # 更新する勤怠データを取得
    @attendance = Attendance.find(params[:attendance][:id])
    # 更新パラメータを文字列で取得する
    @attendance_time = params[:attendance][:attendance_time]
    
    if @attendance_time == params[:attendance][:attendance_time]
      # 出社時刻を更新
      if !@attendance.update_column(:attendance_time, DateTime.now)
        flash[:error] = "出社時間の入力に失敗しました"
      end
    end
    #出社・退社押下した日付及び現在のuser idを@userに返す
    @user = @attendance.user
    attendance_time = Time.new(Time.now.year,Time.now.month,Time.now.day,Time.new.hour,Time.now.min,00)
    @attendance.update(attendance_time: attendance_time)
    redirect_to @user
  end
  
  
  def leaving_update
    # 更新する勤怠データを取得
    @attendance = Attendance.find(params[:attendance][:id])
    # 更新パラメータを文字列で取得する
    @leaving_time = params[:attendance][:leaving_time]
    if @leaving_time == params[:attendance][:leaving_time]
      # 退社時刻を更新
      if !@attendance.update_column(:leaving_time, DateTime.now)
        flash[:error] = "退社時間の入力に失敗しました"
      end
    end
    #出社・退社押下した日付及び現在のuser idを@userに返す
    @user = @attendance.user
    leaving_time = Time.new(Time.now.year,Time.now.month,Time.now.day,Time.new.hour,Time.now.min,00)
    @attendance.update(leaving_time: leaving_time)
    redirect_to @user
  end
  
  def edit
    if current_user.admin?
      @user = current_user
    end
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @day_of_week = %w[日 月 火 水 木 金 土]
    # 上長ユーザを全取得
    ids = [@user.applied_last_time_user_id]
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact    
    
    # 表示月があれば取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # ないなら今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    @last_day = @first_day.end_of_month
    
    # 期間分のデータチェック
    (@first_day..@last_day).each do |date|
      # 該当日付のデータがないなら作成する
      if !@user.attendances.any? {|attendance| attendance.day == date }
        attend = Attendance.create(user_id: @user.id, day:date)
        attend.save
      end
    end
    
    # 表示期間の勤怠データを日付順にソートして取得
    @attendances = @user.attendances.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
  end
  
  def edit_all
    # byebug
    @user = User.find(params[:id])
    error_count = attendances_check
    if error_count > 0 
      flash[:warning] = '編集項目にエラーがあります。'
      redirect_to edit_attendance_path(@attendances, params: { id: @user.id, first_day: @first_day }) and return
    end
    
    params[:attendances].each do |id, item|
      attendance = Attendance.find(id)
      # byebug
      attendances_check()
      if error_count = 0
        item.permit
        attendance.update_attributes(
        attendance_time: item["attendance_time"],
        leaving_time: item["leaving_time"],
        remarks: item["remarks"])
        flash[:success] = '勤怠時間を更新しました。'
      else return
      end
    end
    redirect_to user_url(@user, params:{ id: @user.id, first_day: params[:first_day]}) and return
  end
  
    # 申請された1ヵ月分の勤怠を更新する（承認/否認など）
  def update_onemonth_applied_attendance
    
    # 変更チェックが1つ以上で勤怠変更情報を更新
    if !params[:check].blank?
      params[:application].each do |id, item|
        # 更新チェックがなければ何もしない
        if !params[:check].include?(id)
          next
        end
        
        attendance = OneMonthAttendance.find(id)
        if attendance.blank?
          next
        end
        # 申請情報更新
        attendance.update_attributes(item.permit(:application_state))
      end
    end

    @user = User.find(params[:id])
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
  end
  
  # 残業申請の編集
  def edit_overtime
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @youbi = %w[日 月 火 水 木 金 土]
    # 上長ユーザを全取得
    ids = [@user.applied_last_time_user_id]
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact
    
    # 表示月があれば取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # ないなら今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    @last_day = @first_day.end_of_month
    
    # 期間分のデータチェック
    (@first_day..@last_day).each do |date|
      # 該当日付のデータがないなら作成する
      if !@user.attendances.any? {|attendance| attendance.day == date }
        attend = Attendance.create(user_id: @user.id, day:date)
        attend.save
      end
    end
    
    # 表示期間の勤怠データを日付順にソートして取得
    @attendances = @user.attendances.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
  end
  
  
  
end