# frozen_string_literal: true

class CommentAndPostVoteDistinctLocking < ActiveRecord::Migration[7.1]
  def change
    add_column(:comment_votes, :is_locked, :boolean, null: false, default: false)
    add_column(:post_votes, :is_locked, :boolean, null: false, default: false)
  end
end
