class RemoveDesignatedWorkStartTimeFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :designated_work_start_time, :time
  end
end
