class CreateNewsArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :news_articles do |t|
      t.string :title
      t.text :description
      t.string :url
      t.datetime :published_at
      t.string :query

      t.timestamps
    end
  end
end
