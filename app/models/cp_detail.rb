class CpDetail < ActiveRecord::Base
   validates_presence_of :cpName, :message => 'can\'t be blank'
   validates_presence_of :partner, :number, :vessel, :from, :to, :currency, :user_id
   validates_numericality_of :number
   has_many :port_details
   has_one :report_card
   belongs_to :user

   DEMURRAGE = ['Always', 'Not Always']

   default_value_for :once_on_demurrage, DEMURRAGE[0]

   HUMANIZED_COLLUMNS = {:cpName => "Form name", :number => "No."}
   def self.human_attribute_name(attribute)
     HUMANIZED_COLLUMNS[attribute.to_sym] || super
   end
end
