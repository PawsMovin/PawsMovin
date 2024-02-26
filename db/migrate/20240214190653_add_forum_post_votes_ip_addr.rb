# frozen_string_literal: true

class AddForumPostVotesIpAddr < ActiveRecord::Migration[7.1]
  def change
    rename_column :forum_post_votes, :creator_id, :user_id
    add_column :forum_post_votes, :user_ip_addr, :inet, null: false, default: "127.0.0.1"
    change_column_default :forum_post_votes, :user_ip_addr, from: "127.0.0.1", to: nil
  end
end
