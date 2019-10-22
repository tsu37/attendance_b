class AddScheduledendhourToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :scheduled_end_hour, :datetime
  end
end
