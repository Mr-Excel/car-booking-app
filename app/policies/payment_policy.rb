class PaymentPolicy < ApplicationPolicy
  def show?
    user.id == record.booking.user_id
  end
end 