FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    subtitle { Faker::Movie.title }
    blurb { Faker::Lorem.paragraphs(number: 5).join("\n") }
    publisher { Faker::Book.publisher }
    author { FactoryBot.create(:author) }
    number_of_pages { Faker::Number.number(digits: 3)}
    has_been_read { ['Yes', 'In progress', 'No'].sample }
  end
end
