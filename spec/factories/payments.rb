FactoryBot.define do
  factory :payment do
    booking { nil }
    amount { "9.99" }
    payment_method { "MyString" }
    transaction_id { "MyString" }
    status { "MyString" }
    tenant { nil }
  end
end
