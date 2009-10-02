class AddPortDetailIdToFacts < ActiveRecord::Migration
  def self.up
    add_column :facts, :port_detail_id, :integer
  end

  def self.down
    remove_column :facts, :port_detail_id
  end
end
