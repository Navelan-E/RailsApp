class AddResourceOwnerTypeToOauthAccessTokens < ActiveRecord::Migration[7.1]
  def change
    add_column :oauth_access_tokens, :resource_owner_type, :string
  end
end
