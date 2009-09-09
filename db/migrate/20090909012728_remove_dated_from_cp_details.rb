class RemoveDatedFromCpDetails < ActiveRecord::Migration
  def self.up
    remove_column :cp_details, :dated
  end

  def self.down
    add_column :cp_details, :dated, :date
  end
end
