# frozen_string_literal: true

class AddVoiceActorTagCategory < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :tag_count_voice_actor, :integer, default: 0, null: false
  end
end
