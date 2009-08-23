class CreateTimeInfos < ActiveRecord::Migration
  def self.up
    create_table :time_infos do |t|
      t.integer :days
      t.integer :hours
      t.integer :mins
      t.string :type
      t.integer :port_detail_id

      t.timestamps
    end
  end

  def self.down
    drop_table :time_infos
  end
end
