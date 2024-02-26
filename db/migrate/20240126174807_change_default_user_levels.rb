# frozen_string_literal: true

class ChangeDefaultUserLevels < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :level, from: 20, to: User::Levels::MEMBER
    change_column_default :forum_categories, :can_view, from: 20, to: User::Levels::MEMBER
    change_column_default :forum_categories, :can_create, from: 20, to: User::Levels::MEMBER
    change_column_default :forum_categories, :can_reply, from: 20, to: User::Levels::MEMBER
  end
end
