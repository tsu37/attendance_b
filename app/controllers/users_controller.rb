class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :edit_basic_info, :destroy]
  before_action :admin_or_correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index, :edit_basic_info, :update_basic_info, :destroy]

  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  
  def show
    if current_user.admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    
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
    end
    @work_sum /= 3600
  end
  def att_export
    # byebug
    @user = User.find(params[:id])
    # @user = User.all
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
    end
    @work_sum /= 3600

    # CSV出力ファイル名を指定
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "#{@first_day.strftime("%Y年%m月")}_#{@user.name}.csv", type: :csv
      end
    end
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

  # 基本情報の編集
  def edit_basic_info
    # 1つしかないので先頭を取得
    @basic_info = BasicInfo.find_by(id: 1)
    # なければ作成する
    if @basic_info.nil?
      @basic_info = BasicInfo.new
      @basic_info.save
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
   
  def csv_import
    if params[:csv_file].blank?
      flash[:danger] = "読み込むCSVを選択してください。"
      redirect_to users_url
    elsif File.extname(params[:csv_file].original_filename) != ".csv"
      flash[:danger] = "csvファイルのみ読み込み可能です。"
      redirect_to users_url
    else
      msg = User.import(params[:csv_file])
      msg == "登録完了" ? flash[:success] = msg : flash[:danger] = msg
      redirect_to users_url
    end 
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,:affiliation,
                                   :basic_work_hour, :design_work_hour, :password_confirmation)
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