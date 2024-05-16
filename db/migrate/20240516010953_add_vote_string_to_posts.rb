# frozen_string_literal: true

class AddVoteStringToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column(:posts, :vote_string, :string, default: "", null: false)
  end
end
