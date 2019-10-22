class AddOvertimeWorkToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_work, :text
    add_column :attendances, :authorizer_user_id_of_attendances, :integer
    add_column :attendances, :before_edited_work_start, :datetime
  end
end
