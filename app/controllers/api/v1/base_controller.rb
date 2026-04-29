class Api::V1::BaseController < ActionController::API
before_action :doorkeeper_authorize!
  def current_resource_owner
    return nil unless doorkeeper_token

    case doorkeeper_token.resource_owner_type
    when "Customer"
      Customer.find_by(id: doorkeeper_token.resource_owner_id)
    when "Mechanic"
      Mechanic.find_by(id: doorkeeper_token.resource_owner_id)
    when "AdminUser"
      AdminUser.find_by(id: doorkeeper_token.resource_owner_id)
    end
  end
end
