# frozen_string_literal: true

class ChangeUsersPerPageDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:users, :per_page, from: 75, to: 100)
  end
end
