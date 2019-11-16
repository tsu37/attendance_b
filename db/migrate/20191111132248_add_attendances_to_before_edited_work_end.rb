class AddAttendancesToBeforeEditedWorkEnd < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :before_edited_work_end, :datetime
  end
end
