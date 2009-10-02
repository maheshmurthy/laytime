class RemoveCpDetailFromFact < ActiveRecord::Migration
  def self.up
    remove_column :facts, :cp_detail_id
  end

  def self.down
    add_column :facts, :cp_detail_id
  end
end
