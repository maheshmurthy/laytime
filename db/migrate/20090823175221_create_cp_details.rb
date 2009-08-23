class CreateCpDetails < ActiveRecord::Migration
  def self.up
    create_table :cp_details do |t|
      t.string :partner
      t.string :cpName
      t.integer :number
      t.date :dated
      t.string :vessel
      t.string :from
      t.string :to
      t.string :details
      t.text :remarks
      t.string :currency

      t.timestamps
    end
  end

  def self.down
    drop_table :cp_details
  end
end
