class PortDetail < ActiveRecord::Base
   validates_presence_of :operation, :location, :cargo, :quantity, :description, :allowanceType, :allowance, :demurrage, :despatch, :calculation_type,:calculation_time_saved, :commission_pct, :time_start_date, :time_start_time, :time_end_date, :time_end_time

   has_many :informative_entries
   has_many :time_infos
   has_many :facts
   before_save :merge_dates
   attr_accessor :time_start_date, :time_start_time, :time_end_date, :time_end_time

   def time_start_date_string
     if time_start
       time_start.to_s(:custom_date)
     elsif time_start_date
       time_start_date
     else
       "dd-mm-yy"
     end
   end

   def time_start_time_string
     if time_start
       time_start.to_s(:custom_time)
     elsif time_start_time
       time_start_time
     else
       "hh:mm"
     end
   end

   def time_end_date_string
     if time_end
       time_end.to_s(:custom_date)
     elsif time_end_date
       time_end_date
     else
       "dd-mm-yy"
     end
   end

   def time_end_time_string
     if time_end
       time_end.to_s(:custom_time)
     elsif time_end_time
       time_end_time
     else
       "hh:mm"
     end
   end

   def merge_dates
     self.time_start = DateTime.strptime(self.time_start_date, "%d-%m-%y")
     time = Time.parse(self.time_start_time)
     self.time_start.advance(:hours => time.hour, :minutes => time.min)

     self.time_end = DateTime.parse(self.time_end_date, "%d-%m-%y")
     time = Time.parse(self.time_end_time)
     self.time_end.advance(:hours => time.hour, :minutes => time.min)
   end
end
