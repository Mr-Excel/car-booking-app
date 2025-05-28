FactoryBot.define do
  factory :driver do
    user { nil }
    vehicle { nil }
    status { "MyString" }
    tenant { nil }
  end
end
