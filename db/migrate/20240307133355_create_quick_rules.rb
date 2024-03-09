class CreateQuickRules < ActiveRecord::Migration[7.1]
  def change
    create_table :quick_rules do |t|
      t.references :rule
      t.string :reason, null: false
      t.string :header
      t.integer :order, null: false
      t.timestamps
    end
  end
end
