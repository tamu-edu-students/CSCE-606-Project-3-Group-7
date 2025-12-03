class RemoveEcefFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :ecef_x, :float
    remove_column :users, :ecef_y, :float
    remove_column :users, :ecef_z, :float
    remove_column :users, :location_updated_at, :datetime
  end
end