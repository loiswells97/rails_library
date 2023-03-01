FactoryBot.define do
  factory :author do
    first_name { Faker::Name.first_name }
    surname { Faker::Name.last_name }

    trait :with_books do
      transient do
        books_count { 1 }
      end

      after(:create) do |author, evaluator|
        author.books << FactoryBot.create_list(:book, evaluator.books_count)
      end
    end
  end
end
