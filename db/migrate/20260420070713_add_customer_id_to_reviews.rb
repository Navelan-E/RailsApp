class AddCustomerIdToReviews < ActiveRecord::Migration[7.1]
  def change
    add_reference :reviews, :customer, null: false, foreign_key: true
  end
end
