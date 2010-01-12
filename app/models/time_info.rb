class TimeInfo < ActiveRecord::Base
   include TimeUtil
   validates_presence_of :days, :hours, :mins, :time_info_type
   belongs_to :port_detail

   TIME_INFO_TYPE = {'Report' => 'Report'}

   def add(info)
     self_mins = self.to_mins
     info_mins = info.to_mins
     total_mins = self_mins + info_mins
     new_info = to_time_info(total_mins)
   end

   def reset
     self.days = 0
     self.hours = 0
     self.mins = 0
   end

   def diff(info)
     self_mins = self.to_mins
     info_mins = info.to_mins
     diff_mins = (self_mins - info_mins).abs
     new_info = to_time_info(diff_mins)
   end

   def to_mins
     return self.days * 24 * 60 + self.hours * 60 + self.mins
   end

   def to_days
     return self.days + self.hours/24.0 + self.mins/(24.0*60.0)
   end

   def greater_than(info)
      self.to_mins > info.to_mins
   end

   def less_than(info)
      self.to_mins < info.to_mins
   end

   def to_s
     self.days.to_s + " days " + pad(self.hours).to_s + ":" + pad(self.mins).to_s
   end
end
