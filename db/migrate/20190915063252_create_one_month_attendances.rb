class CreateOneMonthAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :one_month_attendances do |t|
      t.integer :application_user_id
      t.integer :authorizer_user_id
      t.date :application_date
      t.integer :application_state, default: 0

      t.timestamps
    end
  end
end
