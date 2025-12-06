class AddRoomToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :room, :string
  end
end
