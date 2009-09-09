class CpDetail < ActiveRecord::Base
   validates_presence_of :cpName, :message => 'can\'t be blank'
   validates_presence_of :partner, :number, :vessel, :from, :to, :details, :currency
   has_many :facts
   has_many :port_detail

   HUMANIZED_COLLUMNS = {:cpName => "Form name"}
   def self.human_attribute_name(attribute)
     HUMANIZED_COLLUMNS[attribute.to_sym] || super
   end
end
