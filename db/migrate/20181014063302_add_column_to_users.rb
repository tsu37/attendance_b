class AddColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :design_work_hour, :time
    add_column :users, :basic_work_hour, :time
  end
end
