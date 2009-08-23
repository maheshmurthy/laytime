class CreateInformativeEntries < ActiveRecord::Migration
  def self.up
    create_table :informative_entries do |t|
      t.date :entrydate
      t.string :remarks
      t.integer :port_detail_id

      t.timestamps
    end
  end

  def self.down
    drop_table :informative_entries
  end
end
