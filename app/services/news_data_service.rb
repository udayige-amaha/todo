require "net/http"
require "json"

class NewsDataService
  BASE_URL = "https://newsdata.io/api/1/latest"

  def initialize(query:, country: "in")
    @query = query if query.present?
    @country = country
    @api_key = Rails.application.credentials.dig(:news_data, :api_key)
  end

  def call
    uri = build_uri
    response = fetch_news_data(uri)
    parse_response(response)
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
      {
        success: true,
        data: JSON.parse(response.body)
      }
    when 401
      { error: "Unauthorized: Invalid API key" }
    when 429
      { error: "Too Many Requests: Rate limit exceeded" }
    else
      { error: "Unexpected response code: #{response.code}" }
    end
  end
end
