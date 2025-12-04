class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    # Add role column with default
    add_column :users, :role, :string, default: 'user', null: false
    add_index :users, :role

    # Migrate existing is_admin to role (handles NULL, true, false)
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET role = 'admin' WHERE is_admin = 1"
        execute "UPDATE users SET role = 'user' WHERE is_admin = 0 OR is_admin IS NULL"
      end
      dir.down do
        execute "UPDATE users SET is_admin = 1 WHERE role = 'admin'"
        execute "UPDATE users SET is_admin = 0 WHERE role = 'user' OR role IS NULL"
      end
    end

    # Remove is_admin column after migration
    remove_column :users, :is_admin, :boolean
  end
end
