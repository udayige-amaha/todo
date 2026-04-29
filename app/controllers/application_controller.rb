class ApplicationController < ActionController::API
  include PaginationHelper
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_api_v2_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  # handle response not found
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end

  def current_user
    current_api_v2_user
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

  # def authenticate_user_from_token!
  #   user_email = request.headers["X-User-Email"].presence
  #   user_token = request.headers["X-User-Token"].presence

  #   user = user_email && User.find_by(email: user_email)

  #   if user && Devise.secure_compare(user.authentication_token, user_token)
  #     @current_user = user
  #   else
  #     render json: { error: "Invalid email or token" }, status: :unauthorized
  #   end
  # end
end
