ActiveAdmin.register Part do
  config.per_page = 10

  collection_action :empty_stock, method: :post do
    Part.update_all("stock = 0")
    redirect_to collection_path, alert: "Selected parts have been marked as out of stock."
  end

  collection_action :sync_stock, method: :post do
    Part.find_each do |part|
      total_used = ServicePart.exclude_completed.where(part_id: part.id).sum(:quantity)
      new_stock = [part.stock - total_used, 0].max
      part.update(stock: new_stock)
    end
    redirect_to collection_path, notice: "Stock levels have been synchronized based on usage."
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

  action_item :sync_stock, only: :index do
    link_to "Sync Stock", sync_stock_admin_parts_path, method: :post
  end

  def admin_parts_params
    params.permit(ids: [])
  end

  filter :records,
        as: :select,
        input_html: { multiple: true , style: "width: 20%"}, 
        collection: -> {
          Record.pluck(:created_at, :id)
        },
        input_html: { class: "select2" }
  filter :name,
        as: :select,
        input_html: { multiple: true , style: "width: 20%"}, 
        collection: -> {
          Part.pluck(:name, :id)
        },
        input_html: { class: "select2" }
end
