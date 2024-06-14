# frozen_string_literal: true

class AddNotifiedMentionsToCommentsAndForumPosts < ActiveRecord::Migration[7.1]
  def change
    add_column(:comments, :notified_mentions, :integer, array: true, default: [], null: false)
    add_column(:forum_posts, :notified_mentions, :integer, array: true, default: [], null: false)
  end
end
