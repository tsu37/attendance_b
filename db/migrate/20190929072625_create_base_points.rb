class CreateBasePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :base_points do |t|
      t.string :name
      t.integer :attendance_state, default: 0
      t.integer :integer, default: 0

      t.timestamps
    end
  end
end
