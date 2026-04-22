ActiveAdmin.register Review do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :content, :reviewable_type, :reviewable_id, :customer_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:content, :reviewable_type, :reviewable_id, :customer_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  filter :reviewable_type, as: :select, collection: ['Record', 'Mechanic', 'Vehicle']
  filter :customer, as: :select, collection: proc { Customer.all.pluck(:name, :id) }
  filter :created_at
  filter :updated_at
end
