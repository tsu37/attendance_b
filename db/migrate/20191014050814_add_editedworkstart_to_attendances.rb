class AddEditedworkstartToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edited_work_start, :datetime
    add_column :attendances, :edited_work_end, :datetime
  end
end
