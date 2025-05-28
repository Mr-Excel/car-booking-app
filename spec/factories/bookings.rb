FactoryBot.define do
  factory :booking do
    pickup_location { "MyString" }
    dropoff_location { "MyString" }
    pickup_lat { "9.99" }
    pickup_lng { "9.99" }
    dropoff_lat { "9.99" }
    dropoff_lng { "9.99" }
    distance { "9.99" }
    duration { 1 }
    passengers { 1 }
    pickup_note { "MyText" }
    status { "MyString" }
    payment_status { "MyString" }
    payment_method { "MyString" }
    user { nil }
    driver { nil }
    tenant { nil }
  end
end
