FactoryBot.define do
  factory :author do
    first_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    # first_name {'John'}
    # surname {'Owen'}
  end
end
