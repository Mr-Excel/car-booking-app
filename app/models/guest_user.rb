class GuestUser < ApplicationRecord
  # Tenant association
  belongs_to :tenant
  acts_as_tenant :tenant
  
  # Associations
  has_many :bookings, foreign_key: :user_id, dependent: :nullify
  
  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "only allows numbers, spaces, and symbols: + - ( )" }
  
  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def guest?
    true
  end
end
