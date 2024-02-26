# frozen_string_literal: true

class UpgradeApiKeys < ActiveRecord::Migration[7.1]
  def change
    add_column(:api_keys, :name, :string, default: "", null: false)
    add_column(:api_keys, :permissions, :string, array: true, default: [], null: false)
    add_column(:api_keys, :permitted_ip_addresses, :inet, array: true, default: [], null: false)
    add_column(:api_keys, :uses, :integer, default: 0, null: false)
    add_column(:api_keys, :last_used_at, :datetime)
    add_column(:api_keys, :last_ip_address, :inet)
    remove_index(:api_keys, :user_id, unique: true)
  end
end
