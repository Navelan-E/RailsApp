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
  permit_params :record_id, :part_id, :quantity
  #
  # or
  #
  # permit_params do
  #   permitted = [:record_id, :part_id, :quantity]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  filter :record, as: :select, collection: Record.all.map { |r| ["Record ##{r.id} - #{r.vehicle.number_plate}", r.id] }, input_html: { class: "select2" }
  filter :part, as: :select, collection: Part.all.map { |p| [p.name, p.id] }, input_html: { class: "select2" }
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :id
    column :"Record Id" do |resources|
      resources.record_id
    end
    column :part
    column :quantity
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row "Record Id" do |servicePart|
        link_to servicePart.record.id, admin_record_path(servicePart.record)
      end
      row :part do |servicePart|
        if servicePart.part
          link_to servicePart.part.name, admin_part_path(servicePart.part)
        end
      end
      row :quantity
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Service Details" do
    f.input :part, as: :select, collection: Part.all.map { |p| [p.name, p.id] }, input_html: { class: "select2" }
    f.input :record, as: :select, collection: Record.all.map { |r| [r.id] }, input_html: { class: "select2" }
    f.input :quantity
    end
  f.actions
  end
    
end
