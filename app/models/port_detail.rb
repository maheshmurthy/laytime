class PortDetail < ActiveRecord::Base
   validates_presence_of :operation, :location, :cargo, :quantity, :description, :allowanceType, :allowance, :demurrage, :despatch, :calculation_type,:calculation_time_saved, :commission_pct, :time_start_date, :time_start_time, :time_end_date, :time_end_time

   has_many :informative_entries
   has_many :time_infos
   has_many :facts
   before_save :merge_dates
   attr_accessor :time_start_date, :time_start_time, :time_end_date, :time_end_time

   CALCULATION_TYPE = ['Normal', 'Customary Quick Despatch']
   CALCULATION_TIME_SAVED= ['Working', 'All']

   include TimeUtil

   def time_allowed
     if quantity && allowance
       pretty_time_mins(((quantity/Float(allowance)) * 24 * 60).round)
     else
       ""
     end
   end

   def time_used
     if time_start && time_end
       pretty_time_mins((time_end - time_start) / 60)
     else
       ""
     end
   end

   def time_remaining
      if quantity && allowance && time_start && time_used
        allowed = ((quantity/Float(allowance)) * 24 * 60).round
        used = (time_end - time_start) / 60
        pretty_time_mins((allowed-used).abs)
      else
        ""
      end
   end

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
     debugger
     self.time_start = DateTime.strptime(self.time_start_date, "%d-%m-%y")
     time = Time.parse(self.time_start_time)
     self.time_start = self.time_start.advance(:hours => time.hour, :minutes => time.min)

     self.time_end = DateTime.strptime(self.time_end_date, "%d-%m-%y")
     time = Time.parse(self.time_end_time)
     self.time_end = self.time_end.advance(:hours => time.hour, :minutes => time.min)
   end
end
