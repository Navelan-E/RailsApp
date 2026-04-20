class AddUnlockTokenToMechanics < ActiveRecord::Migration[7.0]
  def change
    add_column :mechanics, :unlock_token, :string
    add_index :mechanics, :unlock_token, unique: true
  end
end
