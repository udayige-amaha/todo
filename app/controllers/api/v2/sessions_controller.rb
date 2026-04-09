class Api::V2::SessionsController < ApplicationController
  before_action :authenticate_user_from_token!, except: :create

  def create
    @user = User.find_by(email: params[:email])
    if @user&.valid_password?(params[:password])
      render json: {
        user: {
          email: @user.email,
          authentication_token: @user.authentication_token
        },
        status: :ok
      }
    else
      render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
    end
  end
end
