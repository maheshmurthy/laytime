class CreateReportCards < ActiveRecord::Migration
  def self.up
    create_table :report_cards do |t|
      t.integer :cp_detail_id
      t.integer :loading_avail_id
      t.integer :discharging_avail_id
      t.integer :loading_used_id
      t.integer :discharging_used_id
      t.decimal :loading_amount, :precision => 10, :scale => 2
      t.decimal :discharging_amount, :precision => 10, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :report_cards
  end
end
