class AddUserIdToCpDetail < ActiveRecord::Migration
  def self.up
    add_column :cp_details, :user_id, :int
  end

  def self.down
    remove_column :cp_details, :user_id
  end
end
