class CreateRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :records do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :mechanic, null: false, foreign_key: true
      t.string :status
      t.integer :total_cost
      t.string :internal_notes

      t.timestamps
    end
  end
  change_column_null :records, :mechanic_id, true
end
