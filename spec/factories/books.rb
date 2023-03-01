FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    publisher { Faker::Book.publisher }
    author { FactoryBot.create(:author) }
    has_been_read { ['Yes', 'In progress', 'No'].sample }
  end
end
