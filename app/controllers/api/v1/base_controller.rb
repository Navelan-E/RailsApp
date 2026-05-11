class Api::V1::BaseController < ActionController::API
  rescue_from Doorkeeper::Errors::TokenForbidden, with: :handle_forbidden
  rescue_from Doorkeeper::Errors::TokenUnknown, with: :handle_unauthorized
  private

  def handle_unauthorized(_exception)
    render json: {
      success: false,
      error: "unauthorized",
      message: "Invalid or expired access token"
    }, status: :unauthorized
  end

  def handle_forbidden(_exception)
    render json: {
      success: false,
      error: "forbidden",
      message: "You do not have permission to access this resource"
    }, status: :forbidden
  end
end
