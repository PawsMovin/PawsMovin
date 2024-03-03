# frozen_string_literal: true

class CreateRules < ActiveRecord::Migration[7.1]
  def change
    create_table(:rules) do |t|
      t.references(:creator, null: false, foreign_key: { to_table: :users })
      t.references(:updater, null: false, foreign_key: { to_table: :users })
      t.references(:category, null: false, foreign_key: { to_table: :rule_categories })
      t.string(:name, null: false)
      t.text(:description, null: false)
      t.integer(:order, null: false)
      t.string(:anchor, null: false)
      t.timestamps
    end
  end
end
