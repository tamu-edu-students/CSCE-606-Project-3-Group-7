class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.float :ecef_x
      t.float :ecef_y
      t.float :ecef_z

      t.timestamps
    end
  end
end
