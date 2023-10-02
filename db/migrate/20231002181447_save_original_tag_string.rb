class SaveOriginalTagString < ActiveRecord::Migration[7.0]
  def change
    add_column :post_versions, :original_tags, :text, null: false, default: ""
    add_column :posts, :original_tag_string, :text, null: false, default: ""
  end
end
