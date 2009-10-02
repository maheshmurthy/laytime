class AddPortDemurrageDetails < ActiveRecord::Migration
  def self.up
    add_column :cp_details, :ports_to_calculate, :string
    add_column :cp_details, :once_on_demurrage, :string
  end

  def self.down
    remove_column :cp_details, :ports_to_calculate
    remove_column :cp_details, :once_on_demurrage
  end
end
