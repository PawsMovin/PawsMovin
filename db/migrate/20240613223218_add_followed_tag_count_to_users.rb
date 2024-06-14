# frozen_string_literal: true

class AddFollowedTagCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column(:users, :followed_tag_count, :integer, null: false, default: 0)
  end
end
