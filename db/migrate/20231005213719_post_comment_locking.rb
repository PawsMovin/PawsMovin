class PostCommentLocking < ActiveRecord::Migration[7.0]
  def change
    Post.without_timeout do
      add_column :posts, :is_comment_locked, :boolean, default: false, null: false
    end
  end
end
