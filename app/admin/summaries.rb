ActiveAdmin.register Summary do
  config.per_page = 10

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :record_id, :summary_text, :customer_notes, :completed_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:record_id, :summary_text, :customer_notes, :completed_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do
    selectable_column
    column :id
    column :"Record Id" do |resources|
      resources.record_id
    end
    column :summary_text
    column :customer_notes
    column :completed_at
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row "Record Id" do |servicePart|
        link_to servicePart.record.id, admin_record_path(servicePart.record)
      end
      row :summary_text
      row :customer_notes
      row :completed_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Summary Details" do
      f.input :summary_text
      f.input :customer_notes
      f.input :completed_at, as: :datepicker
    end
  f.actions
  end
end
