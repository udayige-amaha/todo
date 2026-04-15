FactoryBot.define do
  factory :task do
    title { Faker::Lorem.words(number: 3).join(" ") }
    completed { false }
    priority { rand(0..3) }
    due_date { Faker::Date.forward(days: 30) }
    association :user
  end
end
