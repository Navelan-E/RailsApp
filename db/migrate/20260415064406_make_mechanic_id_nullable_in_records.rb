class MakeMechanicIdNullableInRecords < ActiveRecord::Migration[7.1]
  def change
    change_column_null :records, :mechanic_id, true
  end
end
