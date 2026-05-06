class Api::V1::BaseController < ActionController::API
before_action :doorkeeper_authorize!
end
