class CreateSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :summaries do |t|
      t.references :record, null: false, foreign_key: true
      t.string :summary_text
      t.string :customer_notes
      t.datetime :completed_at

      t.timestamps
    end
  end
end
