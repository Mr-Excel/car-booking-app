FactoryBot.define do
  factory :vehicle do
    model { "MyString" }
    make { "MyString" }
    year { "MyString" }
    license_plate { "MyString" }
    capacity { 1 }
    tenant { nil }
  end
end
