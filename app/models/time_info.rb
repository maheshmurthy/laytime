class TimeInfo < ActiveRecord::Base
   validates_presence_of :days, :hours, :mins, :time_info_type
   belongs_to :port_detail
end
