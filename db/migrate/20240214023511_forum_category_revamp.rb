# frozen_string_literal: true

class ForumCategoryRevamp < ActiveRecord::Migration[7.1]
  def change
    rename_column(:forum_categories, :cat_order, :order)
    remove_column(:forum_categories, :description, :string)
    remove_column(:forum_categories, :can_reply, :integer, default: 10, null: false)
    change_column_null(:forum_categories, :order, false, 0)
    change_column_default(:forum_categories, :can_view, from: 10, to: User::Levels::ANONYMOUS)
  end
end
