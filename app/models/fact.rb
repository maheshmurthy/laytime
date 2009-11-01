class Fact < ActiveRecord::Base
  validates_presence_of :from, :to, :timeToCount, :val
  belongs_to :port_detail

   def from_string
     from.to_s(:custom) if from
   end

   def from_string=(from_str)
     self.from = Time.parse(from_str) if from_str
   end

   def to_string
     to.to_s(:custom) if to
   end

   def to_string=(to_str)
     self.to = Time.parse(to_str) if to_str
   end

end
