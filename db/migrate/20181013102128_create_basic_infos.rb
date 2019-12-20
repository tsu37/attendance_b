class CreateBasicInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :basic_infos do |t|
      t.datetime :basic_work_time
      t.datetime :designated_work_time

      t.timestamps
    end
  end
end
