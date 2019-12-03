class AttendancesController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update_all, :destroy]
  before_action :admin_or_correct_user,   only: [:edit]  
  
  # 出勤・退社ボタン押下
  def attendance
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
  
  def leaving
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
    
    # 期間分のデータチェ��ク
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
  
  def update_all
    @user = User.find(params[:id])
    # 各勤怠情報を更新
    params[:attendance].each do |id, item|
      # 申請者がない行はカット
      if item["authorizer_user_id_of_attendance"].blank?
        next
      end
      attendance = Attendance.find(id)
      attendance.update_attributes(item.permit(:remarks, :overtime_work, :instructor, :authorizer_user_id_of_attendance))
      # 初期値を変更前のカラムにするためparamsにはattendance_time/leaving_timeで渡す
      # 格納先はedited_work_start/end
      # 在社時間ーでエラー表示
      if (item["attendance_time(4i)"]+item["attendance_time(5i)"]).to_i > (item["leaving_time(4i)"]+item["leaving_time(5i)"]).to_i
        if params[:check].nil?
          flash[:danger] = '在社時間がマイナスになっています。'
          redirect_back(fallback_location: root_path) and return
        else
          # 申請者が入力されていたら『申請中』に変更する
          if !item[:authorizer_user_id_of_attendance].blank?
            attendance.applying1! 
            # 申請者の番号も保持
            @user.update_attributes(applied_last_time_user_id: item[:authorizer_user_id_of_attendance])
          end
        end
      elsif item["attendance_time(4i)"].blank? || item["attendance_time(5i)"].blank? || item["leaving_time(4i)"].blank? || item["leaving_time(5i)"].blank?
        # 申請者入力で出社/退社時間が空ならエラー表示
        flash[:danger] = '出社or退社時間が空になっています'
        redirect_back(fallback_location: root_path) and return
      else
        # 申請者が入力されていたら『申請中』に変更する
        if !item[:authorizer_user_id_of_attendance].blank?
          attendance.applying1! 
          # 申請者の番号も保持
          @user.update_attributes(applied_last_time_user_id: item[:authorizer_user_id_of_attendance])
        end
      end
  
      if !item["attendance_time(4i)"].empty? || !item["attendance_time(5i)"].empty?
        attendance.update_column(:edited_work_start, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, item["attendance_time(4i)"].to_i, item["attendance_time(5i)"].to_i))
        
      end
      # 退勤があれば更新
      if !item["leaving_time(4i)"].empty? || !item["leaving_time(5i)"].empty?
        attendance.update_column(:edited_work_end, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, item["leaving_time(4i)"].to_i, item["leaving_time(5i)"].to_i))
      end
      # チェックがあれば翌日の時間で退社扱い
      if !params[:check].nil? && !attendance.edited_work_end.nil?
        if params[:check].include?(attendance.day.to_s)
          attendance.update_column(:edited_work_end, attendance.edited_work_end+1.day)
        end
      end
    end
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
    flash[:success] = "勤務時間を編集し、申請しました。"
  end
  
  # 申請された勤怠編集を更新する（承認や否認する）
  def update_applied_attendance
    
    # 変更チェックが1つ以上で勤怠変更情報を更新
    if !params[:check].blank?
      @attendances = Attendance.where("id in (?)", params[:application_edit_state])
      params[:attendance].each do |id, item|
        # 更新チェックがなければ何もしない
        if !params[:check].include?(id)
          next
        end
        
        attendance = Attendance.find(id)
        if attendance.blank?
          next
        end
        
        # 申請情報更新
        attendance.update_attributes(item.permit(:application_edit_state))
        
        if attendance.approval2?
          # 現在の出勤/退勤時刻を変更前として保持 @note 変更前が空（この日付では初回の変更）なら保存
          attendance.update_attributes(before_edited_work_start: attendance.attendance_time) if attendance.before_edited_work_start.blank?
          attendance.update_attributes(before_edited_work_end: attendance.leaving_time) if attendance.before_edited_work_end.blank?
          # 承認された場合は出勤/退勤時刻を上書きする
          attendance.update_attributes(attendance_time: attendance.edited_work_start, leaving_time: attendance.edited_work_end)
        end
      end
    end
    
    @user = User.find(params[:id])
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
  end
  
  # 1日分の残業を申請する
  def one_overtime_application
    @user = User.find(params[:attendance][:user_id])
    
    # 終了予定時刻が空なら何もしない
    if params[:attendance]["scheduled_end_hour(4i)"].blank? || params[:attendance]["scheduled_end_hour(5i)"].blank?
      flash[:danger] = "残業申請の終了予定時刻が空です"
      redirect_to user_url(@user, params: { id: @user.id, first_day: params[:attendance][:first_day] })
      return
    end
    
    # 申請先が空なら何もしない
    if params[:attendance][:authorizer_user_id].blank?
      flash[:danger] = "残業申請の申請先が空です"
      redirect_to user_url(@user, params: { id: @user.id, first_day: params[:attendance][:first_day] })
      return
    end
    
    attendance = Attendance.find(params[:attendance][:id])
    # 申請者が入力されていたら『申請中』に変更する
    if !params[:attendance][:authorizer_user_id].blank?
      attendance.applying!
      # 申請者の番号も保持
      @user.update_attributes(applied_last_time_user_id: params[:attendance][:authorizer_user_id])
    else
      # 空なら上書きで空とならないよう既存のものをセ��ト
      params[:attendance][:authorizer_user_id] = attendance.authorizer_user_id
    end
    attendance.update_attributes(params.require(:attendance).permit(:business_processing, :authorizer_user_id, :application_state))
    
    # 終了予定時間があれば更新
    if !params[:attendance]["scheduled_end_hour(4i)"].blank? || !params[:attendance]["scheduled_end_hour(5i)"].blank?
      attendance.update_column(:scheduled_end_hour, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, params[:attendance]["scheduled_end_hour(4i)"].to_i, params[:attendance]["scheduled_end_hour(5i)"].to_i))
    end
    
    # 翌日チェックONなら終了予定時間を＋1日する
    if !params[:check].blank?
      attendance.update_column(:scheduled_end_hour, attendance.scheduled_end_hour+1.day)
    end
    
    flash[:success] = "残業申請完了しました"
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:attendance][:first_day] })
  end
  
  # 残業を申請する
  def overtime_application
    @user = User.find(params[:id])
    
    # 変更チェックが1つ以上で各残業申請情報を更新
    if !params[:check].blank?
      params[:attendance].each do |id, item|
        # 更新チェックがなければ何もしない
        if !params[:check].include?(id)
          next
        end
        
        attendance = Attendance.find(id)
        # 申請者が入力されていたら『申請中』に変更する
        if !item[:authorizer_user_id].blank?
          attendance.applying!
          # 申請者の番号も保持
          @user.update_attributes(applied_last_time_user_id: item[:authorizer_user_id])
        else
          # 空なら上書きで空とならないよう既存のものをセット
          item[:authorizer_user_id] = attendance.authorizer_user_id
        end
        attendance.update_attributes(item.permit(:business_processing, :authorizer_user_id, :application_state))
        
        # 終了予定時間があれば更新
        if !item["scheduled_end_hour(4i)"].blank? || !item["scheduled_end_hour(5i)"].blank?
          attendance.update_column(:scheduled_end_hour, Time.zone.local(attendance.day.year, attendance.day.month, attendance.day.day, item["scheduled_end_hour(4i)"].to_i, item["scheduled_end_hour(5i)"].to_i))
        end
      end
    end
    
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })
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
  
  private		  
    def user_params		
      params.require(:user).permit(:name, :email, :affiliation,		
                                    :password, :password_confirmation)		
    end
    
    		
    # beforeアクション		
    # ログイン済みユーザーかどうか確認		
    def logged_in_user		
      unless logged_in?		
        store_location		
        flash[:danger] = "ログインして下さい。"		
        redirect_to login_url		
      end		
    end		
    		
    # 正しいユーザーかどうか確認		
    def correct_user		
      @user = User.find(params[:id])		
      redirect_to(root_url) unless current_user?(@user)		
    end		
    		
    # 管理者かどうか確認		
    def admin_user		
      redirect_to(root_url) unless current_user.admin?		
    end		
    		
    # 正しいユーザーor管理者かどうか確認		
    def admin_or_correct_user		
      @user = User.find(params[:id])		
      if !current_user?(@user) && !current_user.admin?		
        redirect_to(root_url)		
      end		
    end
end