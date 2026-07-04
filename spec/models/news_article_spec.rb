require 'rails_helper'

RSpec.describe NewsArticle, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      news_article = build(:news_article)
      expect(news_article).to be_valid
    end

    it "is not valid without a title" do
      news_article = build(:news_article, title: nil)
      expect(news_article).not_to be_valid
      expect(news_article.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a url" do
      news_article = build(:news_article, url: nil)
      expect(news_article).not_to be_valid
      expect(news_article.errors[:url]).to include("can't be blank")
    end

    it "is not valid with a duplicate url" do
      create(:news_article, url: "https://example.com/article")
      news_article = build(:news_article, url: "https://example.com/article", title: "Another Article", published_at: Time.now)
      expect(news_article).not_to be_valid
      expect(news_article.errors[:url]).to include("has already been taken")
    end

    it "is not valid without a published_at" do
      news_article = build(:news_article, published_at: nil)
      expect(news_article).not_to be_valid
      expect(news_article.errors[:published_at]).to include("can't be blank")
    end
  end
end
