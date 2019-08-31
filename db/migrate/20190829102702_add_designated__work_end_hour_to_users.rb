class AddDesignatedWorkEndHourToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :designated_work_end_hour, :time
  end
end
