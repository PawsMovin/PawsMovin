# frozen_string_literal: true

class MoveCountersToUsersTable < ActiveRecord::Migration[7.1]
  def change
    add_counter_column(:post_count)
    add_counter_column(:post_deleted_count)
    add_counter_column(:post_update_count)
    add_counter_column(:post_flag_count)
    add_counter_column(:favorite_count)
    add_counter_column(:wiki_update_count)
    add_counter_column(:note_update_count)
    add_counter_column(:forum_post_count)
    add_counter_column(:comment_count)
    add_counter_column(:pool_update_count)
    add_counter_column(:set_count)
    add_counter_column(:artist_update_count)
    add_counter_column(:own_post_replaced_count)
    add_counter_column(:own_post_replaced_penalize_count)
    add_counter_column(:post_replacement_rejected_count)
    add_counter_column(:ticket_count)
  end

  def add_counter_column(name)
    add_column(:users, name, :integer, default: 0, null: false)
  end
end
