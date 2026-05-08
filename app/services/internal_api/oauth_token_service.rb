class InternalApi::OauthTokenService

  def self.token
    access_token.token
  end

  def self.access_token
    app = Doorkeeper::Application.first!
    Doorkeeper::AccessToken.find_or_create_for(
      application: app,
      resource_owner: nil,
      scopes: "mechanic:read mechanic:write",
      expires_in: 2.hours,
      use_refresh_token: true
    )
  end
end
