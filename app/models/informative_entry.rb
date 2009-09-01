class InformativeEntry < ActiveRecord::Base
  validates_presence_of :port_detail_id, :entrydate, :remarks
  belongs_to :port_detail
end
