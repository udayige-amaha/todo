FactoryBot.define do
  factory :news_article do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    published_at { Faker::Time.backward(days: 14) }
  end
end
