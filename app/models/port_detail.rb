class PortDetail < ActiveRecord::Base
   validates_presence_of :operation, :location, :cargo, :quantity, :description, :allowanceType, :allowance, :demurrage, :despatch, :calculation_type,:calculation_time_saved, :commission_pct, :time_start, :time_end
   has_many :informative_entries
   has_many :time_infos
   has_many :facts
   attr_accessor :time_start_date, :time_start_time, :time_end_date, :time_end_time

   def time_start_date_string
     time_start_date.to_s(:custom_date) if time_start_date
   end

   def time_start_time_string
     time_start_time.to_s(:custom_time) if time_start_time
   end

   def time_start_date_string=(time_start_str)
     self.time_start_date = Time.parse(time_start_str) if time_start_str
   end

   def time_start_time_string=(time_start_str)
     self.time_start_time = Time.parse(time_start_str) if time_start_str
   end

   def time_end_date_string
     time_end_date.to_s(:custom_date) if time_end_date
   end

   def time_end_time_string
     time_end_time.to_s(:custom_time) if time_end_time
   end

   def time_end_date_string=(time_end_str)
     self.time_end_date = Time.parse(time_end_str) if time_end_str
   end

   def time_end_time_string=(time_end_str)
     self.time_end_time = Time.parse(time_end_str) if time_end_str
   end

   def fix_dates
     self.time_start = self.time_start_date
     self.time_start.hour = self.time_start_time.hour
     self.time_start.min = self.time_start_time.min

     self.time_end = self.time_end_date
     self.time_end.hour = self.time_end_time.hour
     self.time_end.min = self.time_end_time.min
   end
end
