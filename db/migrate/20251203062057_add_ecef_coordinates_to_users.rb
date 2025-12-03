class AddEcefCoordinatesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ecef_x, :float
    add_column :users, :ecef_y, :float
    add_column :users, :ecef_z, :float
  end
end
