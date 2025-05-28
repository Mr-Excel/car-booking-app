class Payment < ApplicationRecord
  # Tenant association
  belongs_to :tenant
  acts_as_tenant :tenant
  
  # Associations
  belongs_to :booking
  
  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, presence: true, inclusion: { in: %w[cash credit_card] }
  validates :status, presence: true, inclusion: { in: %w[pending paid failed refunded] }
  
  # Scopes
  scope :successful, -> { where(status: 'paid') }
  scope :pending, -> { where(status: 'pending') }
  
  # Callbacks
  after_save :update_booking_payment_status, if: :saved_change_to_status?
  
  private
  
  def update_booking_payment_status
    booking.update(payment_status: status)
  end
end
