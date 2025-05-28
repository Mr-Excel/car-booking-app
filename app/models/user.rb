class User < ApplicationRecord
  # Tenant association
  belongs_to :tenant
  acts_as_tenant :tenant

  # Authentication
  has_secure_password

  # Associations
  has_many :bookings, dependent: :destroy
  has_one :driver, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { scope: :tenant_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "only allows numbers, spaces, and symbols: + - ( )" }

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def guest?
    false
  end
end
