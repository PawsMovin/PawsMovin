# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table(:notifications) do |t|
      t.references(:user, null: false)
      t.integer(:category, null: false, default: 0)
      t.json(:data, null: false, default: {})
      t.boolean(:is_read, null: false, default: false)
      t.timestamps
    end
  end
end
