class RenameInFact < ActiveRecord::Migration
  def self.up
    change_column :facts, :from, :datetime
    change_column :facts, :to, :datetime
    change_column :informative_entries, :entrydate, :datetime
    change_column :port_details, :pre_advise_date, :datetime
    change_column :port_details, :time_start, :datetime
    change_column :port_details, :time_end, :datetime
  end

  def self.down
    change_column :facts, :from, :date
    change_column :facts, :to, :date
    change_column :informative_entries, :entrydate, :date
    change_column :port_details, :pre_advise_date, :date
    change_column :port_details, :time_start, :date
    change_column :port_details, :time_end, :date
  end
end
