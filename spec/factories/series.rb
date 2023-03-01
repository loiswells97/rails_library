FactoryBot.define do
  factory :series do
    title { Faker::Book.title }

    trait :with_books do
      transient do
        books_count { 1 }
      end

      after(:create) do |series, evaluator|
        series.books << FactoryBot.create_list(:book, evaluator.books_count)
      end
    end
  end
end
