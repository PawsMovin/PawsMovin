class AddTicketsModel < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :model_type, :string, null: false
    add_column :tickets, :model_id, :integer, null: false

    remove_column :tickets, :qtype, :string, null: false
    remove_column :tickets, :disp_id, :integer, null: false
  end
end
