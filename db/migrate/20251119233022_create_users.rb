class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :display_name
      t.string :avatar_url
      t.boolean :is_admin
      t.float :ecef_x
      t.float :ecef_y
      t.float :ecef_z
      t.datetime :location_updated_at
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
