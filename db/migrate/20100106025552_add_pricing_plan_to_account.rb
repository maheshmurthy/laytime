class AddPricingPlanToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :pricing_plan, :string
  end

  def self.down
    remove_column :accounts, :pricing_plan
  end
end
