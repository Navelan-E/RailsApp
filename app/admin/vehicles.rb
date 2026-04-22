ActiveAdmin.register Vehicle do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :customer_id, :model, :number_plate
  #
  # or
  #
  # permit_params do
  #   permitted = [:customer_id, :model, :number_plate]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  show do
    attributes_table do
      row :customer
      row :model
      row :number_plate
      row :created_at
      row :updated_at
      row :records do |vehicle|
        vehicle.records.map do |record|
          link_to "Record ##{record.id} created_at #{record.created_at}", admin_record_path(record)
        end.join(", ").html_safe
      end
    end
  end
end
