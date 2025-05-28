FactoryBot.define do
  factory :guest_user do
    first_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    tenant { nil }
  end
end
