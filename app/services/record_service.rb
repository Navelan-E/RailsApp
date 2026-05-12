class RecordService
  def initialize(record:, params:)
    @record = record
    @params = params
  end

  def create_vehicle_customer_and_tags
    rp = record_params

    customer = Customer.find_by(phone: rp[:customer_phone])

    unless customer
      customer = Customer.create!(
        name: rp[:customer_name],
        email: rp[:customer_email],
        phone: rp[:customer_phone],
        password: "123456",
        password_confirmation: "123456"
      )
    end

    vehicle = Vehicle.find_by(number_plate: rp[:vehicle_no])

    unless vehicle
      vehicle = Vehicle.create!(
        number_plate: rp[:vehicle_no],
        model: rp[:model],
        customer: customer
      )
    end

    { customer: customer, vehicle: vehicle }
  end

    def set_parts
      part_id = @params.dig(:record, :part_id)
      quantity = @params.dig(:record, :part_quantity)

      return true if part_id.blank? || quantity.to_i <= 0

      service_part = ServicePart.find_or_initialize_by(
        record_id: @record.id,
        part_id: part_id
      )

      service_part.quantity = quantity

      if service_part.save
        @part = Part.find(part_id)
        true
      else
        false
      end
    end

    def create_service_tags
      rp = record_params

      valid_tag_ids = rp[:tag_ids].reject(&:blank?)
      tags = valid_tag_ids.present? ? Tag.where(id: valid_tag_ids).to_a : []

      if rp[:custom_tags].present?
        custom_tags = rp[:custom_tags].split(",").map(&:strip).reject(&:empty?)

        custom_tags.each do |tag_name|
          tag = Tag.find_or_create_by!(tag: tag_name)
          tags << tag unless tags.include?(tag)
        end
      end

      @record.tags = tags
    end
 private

  def record_params
    @params.require(:record).permit(
      :internal_notes,
      :vehicle_no,
      :model,
      :customer_name,
      :customer_phone,
      :customer_email,
      :custom_tags,
      tag_ids: []
    )
  end
end
