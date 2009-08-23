class CreateFacts < ActiveRecord::Migration
  def self.up
    create_table :facts do |t|
      t.date :from
      t.date :to
      t.string :timeToCount
      t.float :val
      t.string :remarks
      t.integer :cp_detail_id

      t.timestamps
    end
  end

  def self.down
    drop_table :facts
  end
end
