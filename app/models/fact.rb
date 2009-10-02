class Fact < ActiveRecord::Base
  validates_presence_of :from, :to, :timeToCount, :val, :remarks
  belongs_to :port_detail
end
