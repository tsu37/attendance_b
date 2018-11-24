class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.datetime :attendance_time
      t.datetime :leaving_time
      t.date :day
      t.datetime :attendance_time_edit
      t.datetime :leaving_time_edit
      t.text :remarks

      t.timestamps
    end
  end
end
