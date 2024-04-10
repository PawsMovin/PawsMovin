# frozen_string_literal: true

class AddPostReplacementRejector < ActiveRecord::Migration[7.1]
  def change
    add_reference(:post_replacements, :rejector, foreign_key: { to_table: :users })
    add_column(:post_replacements, :rejection_reason, :string, null: false, default: "")
  end
end
