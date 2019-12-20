class RenameDesignatedWorkHourColumnToBasicInfos < ActiveRecord::Migration[5.1]
  def change
    remove_column :basic_infos, :designated_work_time
  end
end
