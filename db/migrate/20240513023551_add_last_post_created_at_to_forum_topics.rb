# frozen_string_literal: true

class AddLastPostCreatedAtToForumTopics < ActiveRecord::Migration[7.1]
  def change
    add_column(:forum_topics, :last_post_created_at, :datetime)
  end
end
