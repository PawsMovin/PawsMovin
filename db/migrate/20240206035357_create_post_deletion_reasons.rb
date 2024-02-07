
class CreatePostDeletionReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :post_deletion_reasons do |t|
      t.references :creator, foreign_key: { to_table: :users }, null: false
      t.string :reason, null: false
      t.string :title
      t.string :prompt
      t.integer :order, null: false
      t.timestamps
    end
  end
end
