class ApplicationController < ActionController::API
  include PaginationHelper

  before_action :authenticate_user_from_token!

  # handle response not found
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def current_user
    @current_user
  end

  private

  def record_not_found
    render json: { error: "Record not found" }, status: :not_found
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def authenticate_user_from_token!
    user_email = request.headers["X-User-Email"].presence
    user_token = request.headers["X-User-Token"].presence

    user = user_email && User.find_by(email: user_email)

    if user && Devise.secure_compare(user.authentication_token, user_token)
      @current_user = user
    else
      render json: { error: "Invalid email or token" }, status: :unauthorized
    end
  end
end
