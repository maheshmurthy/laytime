class Fact < ActiveRecord::Base
  validates_presence_of :from, :to, :timeToCount, :val
  belongs_to :port_detail
  attr_accessor :from_date, :from_time, :to_date, :to_time

   def from_date_string
     from.to_s(:custom_date) if from_date
   end

   def from_date_string=(from_date_str)
     self.from_date = Time.parse(from_date_str) if from_date_str
   end

   def from_time_string
     from_time.to_s(:custom_time) if from_time
   end

   def from_time_string=(from_time_str)
     self.from_time = Time.parse(from_time_str) if from_time_str
   end

   def to_date_string
     to_date.to_s(:custom_date) if to_date
   end

   def to_date_string=(to_date_str)
     self.to_date = Time.parse(to_date_str) if to_date_str
   end

   def to_time_string
     to_time.to_s(:custom_time) if to_time
   end

   def to_time_string=(to_time_str)
     self.to_time = Time.parse(to_time_str) if to_time_str
   end

   def fix_facts_date
     self.from = self.from_date
     self.from.hour = self.from_time.hour
     self.from.min = self.from_time.min

     self.to = self.to_date
     self.to.hour = self.to_time.hour
     self.to.min = self.to_time.min
   end
end
