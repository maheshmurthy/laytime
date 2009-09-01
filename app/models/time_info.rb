class TimeInfo < ActiveRecord::Base
   validates_presence_of :port_detail_id, :days, :hours, :mins, :type
   belongs_to :port_detail
end
