# frozen_string_literal: true

class DropBlips < ActiveRecord::Migration[7.0]
  def change
    drop_table :blips do |t|
      t.inet :creator_ip_addr, null: false
      t.integer :creator_id, foreign_key: { to_table: :users }, null: false
      t.string :body, null: false
      t.integer :response_to, foreign_key: { to_table: :blips }
      t.boolean :is_hidden, default: false
      t.integer :warning_type
      t.integer :warning_user_id, foreign_key: { to_table: :users }
      t.integer :updater_id, foreign_key: { to_table: :users }
      t.timestamps
    end

    remove_column :user_statuses, :blip_count, :integer, default: 0
  end
end
