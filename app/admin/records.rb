ActiveAdmin.register Record do

  batch_action :mark_as_completed do |ids|
    Record.where(id: ids).update_all(status: "completed", updated_at: Time.current)
    redirect_to collection_path, alert: "Selected records have been marked as completed."
  end

  batch_action :mark_as_in_progress do |ids|
    Record.where(id: ids).update_all(status: "in_progress", updated_at: Time.current)
    redirect_to collection_path, notice: "Selected records have been marked as in progress."
  end

  batch_action :mark_as_pending do |ids|
    Record.where(id: ids).update_all(status: "pending", updated_at: Time.current)
    redirect_to collection_path, alert: "Selected records have been marked as pending."
  end

  collection_action :mark_all_completed, method: :post do
    Record.where.not(status: "completed").update_all(status: "completed", updated_at: Time.current)
    redirect_to collection_path, alert: "All records have been marked as completed."
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :vehicle_id, :mechanic_id, :status, :total_cost, :internal_notes, part_ids: [], tag_ids: []
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

  index do
    selectable_column
    id_column
    column "Vehicle" do |resource|
      link_to resource.vehicle.number_plate, admin_vehicle_path(resource.vehicle)
    end
    column "Mechanic" do |resource|
      if resource.mechanic&.name
        link_to resource.mechanic&.name, admin_mechanic_path(resource.mechanic)
      else 
        "Unassigned"
      end
    end
    column :status
    column :total_cost
      actions
  end
  show do
    attributes_table do
      row :vehicle do |record|
        link_to record.vehicle.number_plate, admin_vehicle_path(record.vehicle)
      end
      row :mechanic do |record|
        if record.mechanic
          link_to record.mechanic.name, admin_mechanic_path(record.mechanic)
        end
      end
      row :status
      row :total_cost
      row :internal_notes
      row :created_at
      row :updated_at
      row :parts do |record|
        record.parts.map do |part|
          link_to part.name, admin_part_path(part)
        end.join(", ").html_safe
      end
      row :tags do |record|
        record.tags.map do |tag|
          link_to tag.name, admin_tag_path(tag)
        end.join(", ").html_safe
      end
    end
  end

  form do |f|
    f.inputs "Record Details" do
      f.input :vehicle, as: :select, collection: Vehicle.all.map { |v| [v.number_plate, v.id] }, input_html: { class: "select2" }
      f.input :mechanic, as: :select, collection: Mechanic.all.map { |m| [m.name, m.id] }, input_html: { class: "select2" }
      f.input :status, as: :select, collection: Record.statuses.keys, input_html: { class: "select2" }
      f.input :total_cost
      f.input :internal_notes
      f.inputs "Parts" do
        li do
          link_to "Add New Part", new_admin_part_path, target: "_blank", class: "button"
        end
        f.has_many :service_parts, allow_destroy: true, new_record: "Add Part" do |op|
          op.input :part_id, as: :select, collection: Part.pluck(:name, :id), input_html: { class: "select2" }
          op.input :quantity
        end
      end
      f.inputs "Tags Management" do
        li do
          link_to "Add New Tags", new_admin_tag_path, target: "_blank", class: "button"
        end
      f.input :tags, 
        as: :select, 
        input_html: { multiple: true , style: "width: 20%"}, 
        collection: Tag.all.map { |t| [t.tag, t.id] },
        input_html: { class: "select2" }
      end
    end
  f.actions
  end

  action_item :mark_all_completed, only: :index do
    link_to "Mark All as Completed", mark_all_completed_admin_records_path, method: :post
  end
end
