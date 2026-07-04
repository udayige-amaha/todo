class NewsArticle < ApplicationRecord
  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  validates :published_at, presence: true
end
