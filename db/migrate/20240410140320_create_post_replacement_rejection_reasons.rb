# frozen_string_literal: true

class CreatePostReplacementRejectionReasons < ActiveRecord::Migration[7.1]
  def change
    create_table(:post_replacement_rejection_reasons) do |t|
      t.references(:creator, foreign_key: { to_table: :users }, null: false)
      t.string(:reason, null: false)
      t.integer(:order, null: false)
      t.timestamps
    end
  end
end
