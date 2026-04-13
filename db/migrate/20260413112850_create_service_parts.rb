class CreateServiceParts < ActiveRecord::Migration[7.1]
  def change
    create_table :service_parts do |t|
      t.references :record, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
