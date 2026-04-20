class AddLockableToMechanics < ActiveRecord::Migration[7.1]
  def change
    add_column :mechanics, :failed_attempts, :integer, default: 0, null: false
    add_column :mechanics, :locked_at, :datetime
  end
end
