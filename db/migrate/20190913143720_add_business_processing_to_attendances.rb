class AddBusinessProcessingToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :business_processing, :text
  end
end
