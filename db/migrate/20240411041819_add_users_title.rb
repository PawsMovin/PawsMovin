# frozen_string_literal: true

class AddUsersTitle < ActiveRecord::Migration[7.1]
  def change
    add_column(:users, :title, :string)
  end
end
