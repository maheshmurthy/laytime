class RenameTypeToTimeInfoType < ActiveRecord::Migration
  def self.up
    rename_column :time_infos, :type, :time_info_type
  end

  def self.down
    rename_column :time_infos, :time_info_type, :type
  end
end
