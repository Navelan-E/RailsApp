class AddLockableToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :failed_attempts, :integer, default: 0, null: false unless column_exists?(:customers, :failed_attempts)
    add_column :customers, :unlock_token, :string unless column_exists?(:customers, :unlock_token)
    add_column :customers, :locked_at, :datetime unless column_exists?(:customers, :locked_at)

    add_index :customers, :unlock_token, unique: true unless index_exists?(:customers, :unlock_token)
  end
end
