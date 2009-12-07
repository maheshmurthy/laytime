class Fact < ActiveRecord::Base
  validates_presence_of :timeToCount, :val, :from_date, :from_time, :to_date, :to_time
  belongs_to :port_detail
  attr_accessor :from_date, :from_time, :to_date, :to_time
  before_save :merge_fact_date

   def from_date_string
     if from
       from.to_s(:custom_date)
     elsif from_date
       from_date
     else
       "dd-mm-yy"
     end
   end

   def from_time_string
     if from
       from.to_s(:custom_time)
     elsif from_time 
       from_time
     else
       "hh:mm"
     end
   end

   def from_string
    from.to_s(:custom_date_time)
   end

   def to_date_string
     if to
       to.to_s(:custom_date)
     elsif to_date 
       to_date
     else
       "dd-mm-yy"
     end
   end

   def to_time_string
     if to
       to.to_s(:custom_time)
     elsif to_time
       to_time
     else
       "hh:mm"
     end
   end

   def to_string
    to.to_s(:custom_date_time)
   end

   def from_date_day_string
     if from
       from.strftime("%a")
     elsif from_date
       from_date.strftime("%a")
     else
       "---"
     end
   end

   def to_date_day_string
     if to
       to.strftime("%a")
     elsif to_date
       to_date.strftime("%a")
     else
       "---"
     end
   end

   def merge_fact_date
     self.from = DateTime.strptime(self.from_date, "%d-%m-%y")
     time = Time.parse(from_time)
     self.from = self.from.advance(:hours => time.hour, :minutes => time.min)

     self.to = DateTime.strptime(self.to_date, "%d-%m-%y")
     time = Time.parse(to_time)
     self.to = self.to.advance(:hours => time.hour, :minutes => time.min)
   end
end
