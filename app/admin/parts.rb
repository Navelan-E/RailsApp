ActiveAdmin.register Part do

  collection_action :empty_stock, method: :post do
    puts "Emptying stock for parts with IDs: #{}"
    Part.where(id: params[:ids]).update_all("stock = 0")
    redirect_to collection_path, alert: "Selected parts have been marked as out of stock."
  end
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :price, :stock
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :price, :stock]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  #
  action_item :empty_stock, only: :index do
    link_to "Empty Stock", empty_stock_admin_parts_path, method: :post
  end

  def admin_parts_params
    params.permit(ids: [])
  end
end
