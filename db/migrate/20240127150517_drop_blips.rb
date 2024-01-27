class DropBlips < ActiveRecord::Migration[7.0]
  def change
    drop_table :blips
  end
end
