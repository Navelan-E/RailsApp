class FixMechanicLockableColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :mechanics, :failed_attempts, :integer, default: 0, null: false unless column_exists?(:mechanics, :failed_attempts)
    add_column :mechanics, :locked_at, :datetime unless column_exists?(:mechanics, :locked_at)
  end
end
