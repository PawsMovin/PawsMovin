# frozen_string_literal: true

class AddReplacementsPreviousDetails < ActiveRecord::Migration[7.0]
  def change
    add_column(:post_replacements, :previous_details, :jsonb)
  end
end
