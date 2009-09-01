class CpDetail < ActiveRecord::Base
   validates_presence_of :partner, :cpName, :number, :dated, :vessel, :from, :to, :details
   has_many :facts
   has_many :port_detail
end
