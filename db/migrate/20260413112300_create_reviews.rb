class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.string :content
      t.references :reviewable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
