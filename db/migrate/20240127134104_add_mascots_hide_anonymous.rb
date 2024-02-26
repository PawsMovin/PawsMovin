# frozen_string_literal: true

class AddMascotsHideAnonymous < ActiveRecord::Migration[7.0]
  def change
    add_column :mascots, :hide_anonymous, :boolean, null: false, default: false
  end
end
