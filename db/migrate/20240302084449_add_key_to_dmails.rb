# frozen_string_literal: true

class AddKeyToDmails < ActiveRecord::Migration[7.1]
  def change
    add_column(:dmails, :key, :string, null: false, default: "")
  end
end
