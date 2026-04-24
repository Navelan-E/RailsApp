class ApplicationController < ActionController::API
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
   def configure_permitted_parameters
    if resource_class == Mechanic
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :experience])
        devise_parameter_sanitizer.permit(:account_update, keys: [:name, :experience])
    elsif resource_class == Customer
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone])
    end
  end

  def any_signed_in?
    unless customer_signed_in? || mechanic_signed_in? || admin_user_signed_in?
      redirect_to root_path, alert: "Please sign in to continue."
    end
  end

  def authenticate_pros?
    unless mechanic_signed_in? || admin_user_signed_in?
      redirect_to root_path, alert: "You must be signed in as a mechanic or admin to access this section."
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :any_signed_in?
  helper_method :authenticate_pros?
  
end
