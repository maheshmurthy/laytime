class CreatePortDetails < ActiveRecord::Migration
  def self.up
    create_table :port_details do |t|
      t.string :operation
      t.string :location
      t.string :cargo
      t.float :quantity
      t.string :description
      t.string :allowanceType
      t.float :allowance
      t.float :demurrage
      t.float :despatch
      t.integer :cp_detail_id
      t.string :calculation_type
      t.string :calculation_time_saved
      t.float :commission_pct
      t.date :pre_advise_date
      t.date :time_start
      t.date :time_end

      t.timestamps
    end
  end

  def self.down
    drop_table :port_details
  end
end
