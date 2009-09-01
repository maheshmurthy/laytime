class PortDetail < ActiveRecord::Base
   validates_presence_of :operation, :location, :cargo, :quantity, :description, :allowanceType, :allowance, :demurrage, :despatch, :calculation_type,:calculation_time_saved, :commission_pct, :pre_advise_date, :time_start, :time_end
   has_many :informative_entries
   has_many :time_infos
end
