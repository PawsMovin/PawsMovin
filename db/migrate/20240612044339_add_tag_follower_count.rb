# frozen_string_literal: true

class AddTagFollowerCount < ActiveRecord::Migration[7.1]
  def change
    add_column(:tags, :follower_count, :integer, default: 0, null: false)
  end
end
