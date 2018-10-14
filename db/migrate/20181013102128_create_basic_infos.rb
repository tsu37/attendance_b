class CreateBasicInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :basic_infos do |t|
      t.datetime :basic_work_hour
      t.datetime :designated_work_hour

      t.timestamps
    end
  end
end
