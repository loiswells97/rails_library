FactoryBot.define do
  factory :book do
    # id { SecureRandom.uuid }
    title { Faker::Book.title }
    publisher { Faker::Book.publisher }
    author { FactoryBot.create(:author) }
    has_been_read { ['Yes', 'In progress', 'No'].sample }
    # id {'123'}
    # title {'hello world'}
    # author {FactoryBot.create(:author)}
  end
end
