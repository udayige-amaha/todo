require "net/http"
require "json"

class NewsDataService
  BASE_URL = "https://newsdata.io/api/1/latest"
  CACHE_TTL = 20.minutes

  def initialize(query:, country: "in")
    @query = query if query.present? # or query.presence
    @country = country
    @api_key = Rails.application.credentials.dig(:news_data, :api_key)
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      uri = build_uri
      response = fetch_news_data(uri)
      parse_response(response)
    end
  end

  def cache_key
    query_part = @query.present? ? @query.downcase.strip.gsub(/\s+/, "_") : "none"
    "news/country:#{@country}/query:#{query_part}"
  end

  def build_uri
    uri = URI(BASE_URL)
    params = { apiKey: @api_key, country: @country }
    params[:q] = @query if @query.present?
    uri.query = URI.encode_www_form(params)
    uri
  end

  def fetch_news_data(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)

  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("Timeout error fetching news data: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("Error fetching news data: #{e.message}")
    nil
  end

  def parse_response(response)
    return { error: "No response received" } if response.nil?

    case response.code.to_i
    when 200
      data = JSON.parse(response.body)
      articles = data["results"] || []
      articles.each do |article|
        NewsArticle.find_or_create_by(url: article["link"]) do |news_article|
          news_article.title = article["title"]
          news_article.description = article["description"]
          news_article.published_at = article["pubDate"]
          news_article.query = @query
        end
      end
      {
        success: true,
        data: data
      }
    when 401
      { error: "Unauthorized: Invalid API key" }
    when 429
      { error: "Too Many Requests: Rate limit exceeded" }
    else
      { error: "Unexpected response code: #{response.code}" }
    end
  end

  def self.clear_cache(query: nil, country: "in")
    query_part = query.present? ? query.downcase.strip.gsub(/\s+/, "_") : "none"
    Rails.cache.delete("news/country:#{country}/query:#{query_part}")
  end
end
