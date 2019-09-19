class AddAppliedLastTimeUserIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :applied_last_time_user_id, :integer
  end
end
