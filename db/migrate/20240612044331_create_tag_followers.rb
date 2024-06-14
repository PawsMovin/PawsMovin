# frozen_string_literal: true

class CreateTagFollowers < ActiveRecord::Migration[7.1]
  def change
    create_table(:tag_followers) do |t|
      t.references(:tag, null: false)
      t.references(:user, null: false)
      t.references(:last_post, foreign_key: { to_table: :posts }, null: true)
      t.timestamps
    end
  end
end
