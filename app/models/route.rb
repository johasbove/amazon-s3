class Route < ActiveRecord::Base
  before_save :normalize

  belongs_to :upload
  has_many :stops

  validates_inclusion_of :action, in: %w( Z R ), message: "action %{value} not valid"
  validates :depot, numericality: { only_integer: true }
  validates :nid, :depot_at, :depot, :action, presence: true

  accepts_nested_attributes_for :stops

  private

  def normalize
    self.nid.upcase!
  end
end
