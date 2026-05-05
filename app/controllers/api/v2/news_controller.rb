class Api::V2::NewsController < ApplicationController
  def index
    service = NewsDataService.new(query: params[:q], country: params[:country]  || "in")
    news_data = service.call

    if news_data[:success]
      render json: news_data[:data], status: :ok
    else
      render json: { error: news_data[:error] }, status: :bad_gateway
    end
  end
end
