class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :edit_basic_info, :destroy]
  before_action :admin_or_correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :edit_basic_info, :update_basic_info, :destroy]

  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
    if current_user.admin?
      redirect_to :action => 'index'
    end
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @day_of_week = %w[日 月 火 水 木 金 土]
    
    #基本情報
    @basic_info = BasicInfo.find_by(id: 1)
    
    # 既に表示月があれば、表示月を取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # 表示月が無ければ、今月分を表示
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    #最終日を取得する
    @last_day = @first_day.end_of_month
    # 今月の初日から最終日の期間分を取得
    (@first_day..@last_day).each do |date|
      # 該当日付のデータがないなら作成する
      #(例)user1に対して、今月の初日から最終日の値を取得する
      
      if !@user.attendances.any? {|attendance| attendance.day == date }
        linked_attendance = Attendance.create(user_id: @user.id, day: date)
        linked_attendance.save
      end
    end
    # 表示期間の勤怠データを日付順にソートして取得 show.html.erb、 <% @attendances.each do |attendance| %>からの情報
    @attendances = @user.attendances.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
    # 出勤日数を取得
    @attendance_days = @attendances.where.not(attendance_time: nil, leaving_time: nil).count
    # 在社時間の総数を取得
    @work_sum = 0
    @attendances.where.not(attendance_time: nil, leaving_time: nil).each do |attendance|
      @work_sum += attendance.leaving_time - attendance.attendance_time
      # 自分に申請中の残業一覧を取得	
      @attendances_over = @attendances.where.not(scheduled_end_hour: nil, authorizer_user_id: nil)
    end
    @work_sum /= 3600
    # 上長ユーザを全取得 @note 自分以外の上長を取得	
    ids = [@user.applied_last_time_user_id]	
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }	
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact	
    # 自身の所属長承認状態取得	
    @one_month_attendance = OneMonthAttendance.find_by(application_user_id: @user.id, application_date: @first_day)	
    # 申請用に新規作成	
    @new_one_month_attendance = OneMonthAttendance.new(application_user_id: @user.id)	
    # 自分に申請中の勤怠編集一覧を取得	
    @edit_applications_to_me = Attendance.where(authorizer_user_id_of_attendance: @user.id, application_edit_state: :applying1)	
    # 存在しないuserは除外
    @edit_applications_to_me = @edit_applications_to_me.select{ |x| !User.find_by(id: x.user_id).nil? }	
    # 名前ごとに分類	
    @edit_applications = @edit_applications_to_me.group_by do |application|	
    User.find_by(id: application.user_id).name	
    end	
    # 承認済みの勤怠編集一覧を取得	
    @edit_log_applications = Attendance.where(user_id: @user.id, application_edit_state: :approval2)	
    # 名前ごとに分類	
    @edit_log_applications = @edit_log_applications.group_by do |application|	
    User.find_by(id: application.user_id).name	
    end	
    # 自分に申請中の残業一覧を取得	
    @applications_to_me = Attendance.where(authorizer_user_id: @user.id, application_state: :applying)	
    # 存在しないuserは除外	
    @applications_to_me = @applications_to_me.select{ |x| !User.find_by(id: x.user_id).nil? }	
    # 名前ごとに分類	
    @overtime_applications = @applications_to_me.group_by do |application|	
    User.find_by(id: application.user_id).name	
    end	
    # 所属長承認の情報取得	
    @one_month_applications_to_me = OneMonthAttendance.where(authorizer_user_id: @user.id, application_state: :applying)	
    # 存在しないuserは除外	
    @one_month_applications_to_me = @one_month_applications_to_me.select{ |x| !User.find_by(id: x.application_user_id).nil? }	
    # 名前ごとに分類	
    @one_month_applications = @one_month_applications_to_me.group_by do |application|	
    User.find_by(id: application.application_user_id).name	
    end
  end
  
  def att_export
    @user = User.find(params[:id])
    # 曜日表示用に使用する
    @day_of_week = %w[日 月 火 水 木 金 土]
    # 基本情報取得
    @basic_info = BasicInfo.find_by(id: 1)
    # 表示月があれば取得する
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      # ないなら今月分を表示する
      @first_day = Date.new(Date.today.year, Date.today.month, 1)
    end
    @last_day = @first_day.end_of_month
    # 表示期間の勤怠データを日付順にソートして取得
    @attendances = @user.attendances.where('day >= ? and day <= ?', @first_day, @last_day).order("day ASC")
    # 出勤日数を取得
    @attendance_days = @attendances.where.not(attendance_time: nil, leaving_time: nil).count

    # 在社時間の総数を取得
    @work_sum = 0
    @attendances.where.not(attendance_time: nil, leaving_time: nil).each do |attendance|
      @work_sum += attendance.leaving_time - attendance.attendance_time
      # 自分に申請中の残業一覧を取得		
      @attendances_over = @attendances.where.not(scheduled_end_time: nil, authorizer_user_id: nil)
    end
    @work_sum /= 3600

    # 上長ユーザを全取得 @note 自分以外の上長を取得
    ids = [@user.applied_last_time_user_id]
    User.where.not(id: @user.id, superior: false).each {|s| ids.push(s.id) if s.id != @user.applied_last_time_user_id }
    @superior_users = ids.collect {|id| User.where.not(id: @user.id, superior: false).detect {|x| x.id == id.to_i}}.compact
    
    # 自身の所属長承認状態取得
    @one_month_attendance = OneMonthAttendance.find_by(application_user_id: @user.id, application_date: @first_day)
    # 申請用に新規作成
    @new_one_month_attendance = OneMonthAttendance.new(application_user_id: @user.id)

    # 自分に申請中の勤怠編集一覧を取得
    @edit_applications_to_me = Attendance.where(authorizer_user_id_of_attendance: @user.id, application_edit_state: :applying1)
    # 存在しないuserは除外
    @edit_applications_to_me = @edit_applications_to_me.select{ |x| !User.find_by(id: x.user_id).nil? }
    # 名前ごとに分類
    @edit_applications = @edit_applications_to_me.group_by do |application|
      User.find_by(id: application.user_id).name
    end

    # 承認済みの勤怠編集一覧を取得
    @edit_log_applications = Attendance.where(user_id: @user.id, application_edit_state: :approval2)
    # 名前ごとに分類
    @edit_log_applications = @edit_log_applications.group_by do |application|
      User.find_by(id: application.user_id).name
    end

    # 自分に申請中の残業一覧を取得
    @applications_to_me = Attendance.where(authorizer_user_id: @user.id, application_state: :applying)
    # 存在しないuserは除外
    @applications_to_me = @applications_to_me.select{ |x| !User.find_by(id: x.user_id).nil? }
    # 名前ごとに分類
    @overtime_applications = @applications_to_me.group_by do |application|
      User.find_by(id: application.user_id).name
    end

    # 所属長承認の情報取得
    @one_month_applications_to_me = OneMonthAttendance.where(authorizer_user_id: @user.id, application_state: :applying)
    # 存在しないuserは除外
    @one_month_applications_to_me = @one_month_applications_to_me.select{ |x| !User.find_by(id: x.application_user_id).nil? }
    # 名前ごとに分類
    @one_month_applications = @one_month_applications_to_me.group_by do |application|
      User.find_by(id: application.application_user_id).name
    end


    # CSV出力ファイル名を指定
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "#{@first_day.strftime("%Y年%m月")}_#{@user.name}.csv", type: :csv
      end
    end
  end
  
  def show_confirm		
    @user = User.find(params[:id])		
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:first_day] })		
  end

  def edit_basic_info
    @user = User.find(1)
      if params[:user].present?
        design_work_hour = params[:user][:design_work_hour]
        basic_work_hour = params[:user][:basic_work_hour]
        @user.update(design_work_hour: design_work_hour, basic_work_hour: basic_work_hour)
        flash[:success] = "基本情報を更新しました。"
        redirect_to @user
      end
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
    log_in@user
    flash[:success]="勤怠システムへようこそ"
    redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "個人情報を更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end
  # 
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました。"
    redirect_to users_url
  end
  
  def attendance_list
    # 更新する勤怠データを取得
    @now_users = []
    User.all.each do |user|
      if user.attendances.any?{|a|
         ( a.day == Date.today &&
           !a.attendance_time.blank? &&
           a.leaving_time.blank? )
          }
        @now_users << user
      end
    end
  end
   
    # 基本情報の更新
  def update_basic_info
    # 1つしかないので先頭を更新
    @basic_info = BasicInfo.find_by(id: 1)
    if !@basic_info.nil?
      if @basic_info.update_attributes(basic_info_params)
        flash[:success] = "基本情報を更新しました"
      else
        flash[:success] = "基本情報の更新に失敗しました"
      end
    else
      flash[:success] = "更新元の情報が存在しないため失敗しました"
    end
    render 'edit_basic_info'
  end 
  
    # 1ヵ月分の勤怠申請
  def onemonth_application
    @user = User.find_by(id: params[:one_month_attendance][:application_user_id])
    # 申請先が空なら何もしない
    if params[:one_month_attendance][:authorizer_user_id].blank?
      flash[:danger] = "所属長承認の申請宛先指定が空です"
      redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
      return
    end
    
    # 更新ユーザが見つからない場合はホームへ戻る
    if @user.nil?
      flash[:error] = "自分のアカウントが見つかりませんでした"
      redirect_to(root_url)
      return
    end

    @one_month_attendance = OneMonthAttendance.find_by(application_user_id: params[:one_month_attendance][:application_user_id], application_date: params[:one_month_attendance][:application_date])
    # データがないなら新規作成
    if @one_month_attendance.nil?
      @one_month_attendance = OneMonthAttendance.new(one_month_attendance_params)
      if !@one_month_attendance.save
        flash[:error] = "所属長承認の申請に失敗しました"
        redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
        return
      end
    else
      if !@one_month_attendance.update_attributes(one_month_attendance_params)
        flash[:error] = "所属長承認の申請に失敗しました"
        redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
        return
      end
    end

    @one_month_attendance.applying!
    # 申請者の番号も保持
    @user.update_attributes(applied_last_time_user_id: @one_month_attendance.authorizer_user_id)
    flash[:success] = "時間管理表を送信しました。"
    redirect_to user_url(@user, params: { id: @user.id, first_day: params[:one_month_attendance][:first_day] })
  end
   
  def import
    if params[:csv_file].blank?
      flash[:danger] = "読み込むCSVを選択してください。"
      redirect_to users_url
    elsif File.extname(params[:csv_file].original_filename) != ".csv"
      flash[:danger] = "CSVファイルのみ読み込み可能です。"
      redirect_to users_url
    else
      msg = User.import(params[:csv_file])
      msg == "CSVインポートに成功しました。" ? flash[:success] = msg : flash[:danger] = msg
      redirect_to users_url
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,:affiliation,
                                   :basic_work_hour, :design_work_hour, :password_confirmation,
                                   :designated_work_start_hour, :designated_work_end_hour)
    end
    
    def one_month_attendance_params
      params.require(:one_month_attendance).permit(:application_user_id, :authorizer_user_id, :application_date, :application_state)
    end
    
    # beforeアクション
    
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
         store_location
        flash[:danger] = "ログインしてください。"
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