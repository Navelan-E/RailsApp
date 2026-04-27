ActiveAdmin.register Customer do
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
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :name, :phone, :email, :reset_password_sent_at, :remember_created_at, :failed_attempts, :locked_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :phone, :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :failed_attempts, :unlock_token, :locked_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
filter :name_cont, label: 'Name'
filter :phone_cont, label: 'Phone'
filter :email_cont, label: 'Email'
  filter :vehicle_plate, as: :string, label: "Vehicle Plate"

  index do
    selectable_column
    id_column
    column :name
    column :phone
    column :email
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :phone
      row :email
      row :created_at
      row :updated_at
      row :remember_created_at
      row :failed_attempts
      row :locked_at
      row :reset_password_sent_at
      row :vehicles do |customer|
        customer.vehicles.map do |vehicle|
          link_to "Vehicle ##{vehicle.number_plate}", admin_vehicle_path(vehicle)
        end.join(", ").html_safe
      end
    end
  end

  form do |f|
    f.inputs "Customer Details" do
    f.input :name, as: :string
    f.input :phone, as: :string
    f.input :unlock_token
    end
  f.actions
  end

  action_item :disable, only: :show do
    link_to "Disable Customer", disable_admin_customer_path(resource), method: :patch if !resource.access_locked?
  end
  action_item :unlock, only: :show do
    link_to "Unlock Customer", unlock_admin_customer_path(resource), method: :patch if resource.access_locked?
  end
end
