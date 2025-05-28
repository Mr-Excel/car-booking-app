class Vehicle < ApplicationRecord
  # Tenant association
  belongs_to :tenant
  acts_as_tenant :tenant

  # Associations
  has_many :drivers, dependent: :nullify

  # Validations
  validates :model, :make, :year, :license_plate, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :license_plate, uniqueness: { scope: :tenant_id }
end
