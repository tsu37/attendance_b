class User < ApplicationRecord
  has_many :attendances
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:   true, length: { maximum: 255 },
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: {minimum: 6}, on: :update, allow_blank: true


  class << self
    # 渡された文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
      
    # ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
  
  def self.import(file)
    # 登録ユーザ配列
    new_users = []
    # 重複id
    overlap_id = []
    
    CSV.foreach(file.path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      

      # id重複する場合はその行のみカット
      if exists?(id: row["id"])
        overlap_id.push(row["id"])
        next
      end
      
      user = new(row.to_hash.slice(*updatable_attributes))
      # パラメータに抜けがあれば全データ入力しない
      if user.valid?
        new_users.push(user)
      else
        return "id#{row["id"]}のデータに不備があったため入力失敗しました。"
      end
    end
    # 可能なデータだけ保存
    new_users.each do |user|
      if !user.save
        return "id#{user.id}のデータ保存時にエラーが発生しました。"
      end
    end
    
    # # 重複したidがあればメッセージに表示(石橋くん確認)
    if overlap_id.count == 0
      return "アップデートに成功しました。"
    else
      message = "id:"
      overlap_id.each do |id|
        message += "#{id},"
      end
      message += "は重複のため登録できませんでした。"
      return message
    end
  end

  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["id", "name", "email", "affiliation", "user_id", "uid", "password", "basic_work_hour", "designated_work_start_hour", "designated_work_end_hour", "admin", "superior"]
  end
  
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # ユーザー検索スコープの作成
  def self.search(search) #ここでのself.はUser.を意味する
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
    else
      all #全て表示。User.は省略
    end
  end
end