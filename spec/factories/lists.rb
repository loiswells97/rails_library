FactoryBot.define do
  factory :list do
    title { Faker::Book.title }
    description { Faker::Religion::Bible.quote}
    is_default { [true, false].sample }

    trait :with_books do
      transient do
        books_count { 1 }
      end

      after(:create) do |list, evaluator|
        list.books << FactoryBot.create_list(:book, evaluator.books_count)
      end
    end
  end
end
