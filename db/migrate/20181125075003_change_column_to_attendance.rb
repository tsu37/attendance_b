class ChangeColumnToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :user_id, :integer
  end
  
  add_foreign_key :attendances, :users
end
