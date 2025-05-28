class BookingPolicy < ApplicationPolicy
  def show?
    user.id == record.user_id
  end

  def cancel?
    user.id == record.user_id && record.can_cancel?
  end
end 