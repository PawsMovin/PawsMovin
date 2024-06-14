# frozen_string_literal: true

class AddSuppressMentionsToUserBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column(:user_blocks, :suppress_mentions, :boolean, default: false, null: false)
  end
end
