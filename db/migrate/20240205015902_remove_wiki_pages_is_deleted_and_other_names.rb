# frozen_string_literal: true

class RemoveWikiPagesIsDeletedAndOtherNames < ActiveRecord::Migration[7.0]
  def change
    remove_column :wiki_pages, :is_deleted, :boolean, default: false, null: false
    remove_column :wiki_pages, :other_names, :string, array: true, default: [], null: false

    remove_column :wiki_page_versions, :is_deleted, :boolean, default: false, null: false
    remove_column :wiki_page_versions, :other_names, :string, array: true, default: [], null: false
  end
end
