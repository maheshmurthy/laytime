class Fact < ActiveRecord::Base
  validates_presence_of :timeToCount, :val, :from_date, :from_time, :to_date, :to_time
  belongs_to :port_detail
  attr_accessor :from_date, :from_time, :to_date, :to_time
  before_save :merge_fact_date

  TIME_TO_COUNT = ['Full/Normal', 'Rain/Bad Weather', 'Not to count', 'Shifting', 'Half', 'Partial', 'Always partial','Always excluded', 'Waiting','Full even if S/H', 'Partial even if S/H']

   def validate
     begin
       parse_date(from_date)
     rescue
       errors.add_to_base "Fact From date is invalid"
     end

     begin
       time = from_time.split('.')
       Integer(time[0])
       Integer(time[1])
     rescue
       errors.add_to_base "Fact From time is invalid"
     end

     begin
       parse_date(to_date)
     rescue
       errors.add_to_base "Fact To date is invalid"
     end

     begin
       to_time.split('.')
       Integer(time[0])
       Integer(time[1])
     rescue
       errors.add_to_base "Fact To time is invalid"
     end
   end

   def from_date_string
     if from
       from.to_s(:custom_date)
     elsif from_date
       from_date
     else
       "dd.mm.yy"
     end
   end

   def from_time_string
     if from
       from.to_s(:custom_time)
     elsif from_time 
       from_time
     else
       "hh.mm"
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
       "dd.mm.yy"
     end
   end

   def to_time_string
     if to
       to.to_s(:custom_time)
     elsif to_time
       to_time
     else
       "hh.mm"
     end
   end

   def to_string
    to.to_s(:custom_date_time)
   end

   def from_date_day_string
     if from
       from.strftime("%a")
     else
       "---"
     end
   end

   def to_date_day_string
     if to
       to.strftime("%a")
     else
       "---"
     end
   end

   def merge_fact_date
     self.from = parse_date(from_date)
     time = from_time.split('.')
     self.from = self.from.advance(:hours => time[0].to_i, :minutes => time[1].to_i)

     self.to = parse_date(to_date)
     time = to_time.split('.')
     self.to = self.to.advance(:hours => time[0].to_i, :minutes => time[1].to_i)
   end

   private

   def parse_date(date_string)
     DateTime.strptime(date_string, "%d.%m.%y")
   end

end
