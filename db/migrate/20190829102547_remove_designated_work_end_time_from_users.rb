class RemoveDesignatedWorkEndTimeFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :designated_work_end_time, :time
  end
end
