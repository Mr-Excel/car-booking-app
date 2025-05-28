class Booking < ApplicationRecord
  # Tenant association
  belongs_to :tenant
  acts_as_tenant :tenant

  # Associations
  belongs_to :user
  belongs_to :driver, optional: true
  has_one :payment, dependent: :destroy
  
  # Validations
  validates :pickup_location, :dropoff_location, :pickup_lat, :pickup_lng, :dropoff_lat, :dropoff_lng, presence: true
  validates :distance, :duration, presence: true
  validates :passengers, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending accepted in_progress completed cancelled] }
  validates :payment_status, presence: true, inclusion: { in: %w[pending paid failed refunded] }
  validates :payment_method, presence: true, inclusion: { in: %w[cash credit_card] }

  # Callbacks
  before_validation :set_default_status, on: :create
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :active, -> { where(status: ['accepted', 'in_progress']) }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }

  # Methods
  def estimated_price
    # Simple calculation based on distance and duration
    # In a real application, this would be more complex
    base_price = 5.0
    price_per_km = 1.5
    price_per_minute = 0.5
    
    base_price + (distance.to_f * price_per_km) + (duration.to_f / 60 * price_per_minute)
  end
  
  def can_cancel?
    ['pending', 'accepted'].include?(status)
  end
  
  private
  
  def set_default_status
    self.status ||= 'pending'
    self.payment_status ||= 'pending'
  end
end
