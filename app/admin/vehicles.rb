ActiveAdmin.register Vehicle do
  config.per_page = 10

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
      row :"Service Records" do |vehicle|
        vehicle.records.map do |record|
          link_to "#{record.id}" , admin_record_path(record)
        end.join(", ").html_safe
      end
    end
  end

  form do |f|
    f.inputs "Record Details" do
      f.input :customer, as: :select, collection: Customer.all.map { |c| [c.name, c.id] }, input_html: { class: "select2" }
      f.input :model
      f.input :number_plate
    end
  f.actions
  end
end
