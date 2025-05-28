class Driver < ApplicationRecord
  # Tenant association
  belongs_to :tenant
  acts_as_tenant :tenant

  # Associations
  belongs_to :user
  belongs_to :vehicle
  has_many :bookings, dependent: :nullify

  # Validations
  validates :status, presence: true, inclusion: { in: %w[available busy offline] }
  validates :user_id, uniqueness: { scope: :tenant_id }

  # Scopes
  scope :available, -> { where(status: 'available') }
end
