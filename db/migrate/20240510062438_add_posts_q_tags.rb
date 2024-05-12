class AddPostsQTags < ActiveRecord::Migration[7.1]
  def change
    add_column(:posts, :qtags, :string, null: false, array: true, default: [])
  end
end
