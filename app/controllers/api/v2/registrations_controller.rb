class Api::V2::RegistrationsController < ApplicationController
  before_action :authenticate_user_from_token!, except: :create

  def create
    @user = User.new(user_params)
    if @user.save
      render json: {
        user: {
          email: @user.email,
          authentication_token: @user.authentication_token
        },
        status: {
          message: "User created successfully"
        }
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
