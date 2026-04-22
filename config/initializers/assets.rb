# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Add Active Admin gem stylesheets to load path for Propshaft
begin
  if Gem.loaded_specs["activeadmin"]
    activeadmin_gem = Gem.loaded_specs["activeadmin"]
    activeadmin_path = activeadmin_gem.gem_dir
    Rails.application.config.assets.paths << File.join(activeadmin_path, "app/assets/stylesheets")
  end
rescue => e
  # Fallback - manually add if Gem loading fails
  Rails.application.config.assets.paths << Rails.root.join("vendor/bundle/ruby/3.2.0/gems/activeadmin-3.5.1/app/assets/stylesheets")
end
