class AddAuthorizerUserIdOfAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :authorizer_user_id_of_attendance, :integer
  end
end
