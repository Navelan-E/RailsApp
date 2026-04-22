ActiveAdmin.register Record do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :vehicle_id, :mechanic_id, :status, :total_cost, :internal_notes
  #
  # or
  #
  # permit_params do
  #   permitted = [:vehicle_id, :mechanic_id, :status, :total_cost, :internal_notes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  filter :vehicle, as: :select, collection: Vehicle.all.map { |v| [v.number_plate, v.id] }
  filter :mechanic, as: :select, collection: Mechanic.all.map { |m| [m.name, m.id] }
  filter :status, as: :select, collection: Record.statuses.keys
  filter :total_cost
  filter :created_at
  filter :updated_at
  filter :internal_notes
end
