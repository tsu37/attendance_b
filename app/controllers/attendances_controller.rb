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
    # byebug
    if current_user.admin?
      @user = current_user
    end
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @day_of_week = %w[日 月 火 水 木 金 土]
    
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
    @user = User.find(params[:id])
    
  end
end