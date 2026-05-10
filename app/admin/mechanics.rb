ActiveAdmin.register Mechanic do
  config.per_page = 10
  member_action :disable, method: :patch do
    unless resource.access_locked?
      resource.lock_access!
      redirect_to admin_customer_path(resource), notice: "Customer disabled successfully."
    end
  end

  member_action :unlock, method: :patch do
    if resource.access_locked?
      resource.unlock_access!
      redirect_to admin_customer_path(resource), notice: "Customer unlocked successfully."
    end
  end

  member_action :view_assigned_records, method: :get do
    redirect_to admin_records_path("q[mechanic_id_eq]" => resource.id)
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :experience, :email, :reset_password_sent_at, :remember_created_at, :failed_attempts, :locked_at, :unlock_token, :password, :password_confirmation
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :experience, :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :failed_attempts, :locked_at, :unlock_token]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  filter :name,
        as: :select, 
        input_html: { multiple: true , style: "width: 20%"}, 
        collection: -> {
          Mechanic.pluck(:name, :id)
        },
        input_html: { class: "select2" }
  filter :email,
        as: :select, 
        input_html: { multiple: true , style: "width: 20%"}, 
        collection: -> {
          Mechanic.pluck(:email, :id)
        },
        input_html: { class: "select2" }
  filter :remember_created_at

  index do
    selectable_column
    id_column
    column :name
    column :experience
    column :email
    column :created_at
    actions
  end

   show do
    attributes_table do
      row :name
      row :experience
      row :email
      row :created_at
      row :updated_at
      row :remember_created_at
      row :failed_attempts
      row :locked_at
      row :reset_password_sent_at
      row :records do |mechanic|
        mechanic.records.map do |record|
          link_to "Record ##{record.id}", admin_record_path(record)
        end.join(", ").html_safe
      end
    end
  end

  form do |f|
    f.inputs "Mechanic Details" do
    f.input :name, as: :string
    f.input :experience, as: :string
    f.input :unlock_token
    f.input :email, as: :string
    f.input :password, as: :string
    end
  f.actions
  end
  action_item :disable, only: :show do
    link_to "Disable Mechanic", disable_admin_mechanic_path(resource), method: :patch if !resource.access_locked?
  end
  action_item :unlock, only: :show do
    link_to "Unlock Mechanic", unlock_admin_mechanic_path(resource), method: :patch if resource.access_locked?
  end
  action_item :view_assigned_records, only: :show do
    link_to "View Assigned Records", view_assigned_records_admin_mechanic_path(resource)
  end
end
