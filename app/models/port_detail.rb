class PortDetail < ActiveRecord::Base
   validates_presence_of :operation, :location, :cargo, :quantity, :description, :allowanceType, :allowance, :demurrage, :despatch, :calculation_type,:calculation_time_saved, :commission_pct, :time_start, :time_end
   has_many :informative_entries
   has_many :time_infos
   has_many :facts

   def time_start_string
     time_start.to_s(:db) if time_start
   end

   def time_start_string=(time_start_str)
     self.time_start = Time.parse(time_start_str) if time_start_str
   end

   def time_end_string
     time_end.to_s(:db) if time_end
   end

   def time_end_string=(time_end_str)
     self.time_end = Time.parse(time_end_str) if time_end_str
   end
end
