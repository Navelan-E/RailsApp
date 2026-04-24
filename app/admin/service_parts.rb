ActiveAdmin.register ServicePart do
  scope :all, default: true
  
  scope :used_parts do |scope|
    scope.used_parts
  end

  scope :parts_in_use do |scope|
    scope.parts_in_use
  end
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :record_id, :part_id, :quantity
  #
  # or
  #
  # permit_params do
  #   permitted = [:record_id, :part_id, :quantity]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  filter :record, as: :select, collection: Record.all.map { |r| ["Record ##{r.id} - #{r.vehicle.number_plate}", r.id] }
  filter :part, as: :select, collection: Part.all.map { |p| [p.name, p.id] }
  filter :quantity
  filter :created_at
  filter :updated_at
end
