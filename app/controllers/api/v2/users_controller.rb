class Api::V2::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  def index
    pagination_data = pagination(User.all, 4)
    render json: {
      user: pagination_data[:records],
      meta: pagination_data[:meta]
    }
  end

  def show
    render json: @user
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
