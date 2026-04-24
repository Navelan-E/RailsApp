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
  
end
