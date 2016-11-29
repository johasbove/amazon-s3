class Stop < ActiveRecord::Base
  belongs_to :route
  
  validates :nid, :latitude, :longitude, :arrives_at, :departs_at, presence: true
end
