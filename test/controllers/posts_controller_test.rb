# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  context "The posts controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user, created_at: 1.month.ago)
      as(@user) do
        @post = create(:post, tag_string: "aaaa")
      end
    end

    context "index action" do
      should "render" do
        get posts_path
        assert_response :success
      end

      context "with a search" do
        should "render" do
          get posts_path, params: { tags: "aaaa" }
          assert_response :success
        end
      end

      context "with an md5 param" do
        should "render" do
          get posts_path, params: { md5: @post.md5 }
          assert_redirected_to(@post)
        end

        should "return error on nonexistent md5" do
          get posts_path(md5: "foo")
          assert_response 404
        end
      end

      context "with a random search" do
        should "render" do
          get posts_path, params: { tags: "order:random" }
          assert_response :success

          get posts_path, params: { random: "1" }
          assert_response :success
        end
      end
    end

    context "show_seq action" do
      should "render" do
        posts = create_list(:post, 3)

        get show_seq_post_path(posts[1].id), params: { seq: "prev" }
        assert_response :success

        get show_seq_post_path(posts[1].id), params: { seq: "next" }
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get post_path(@post), params: { id: @post.id }
        assert_response :success
      end
    end

    context "update action" do
      should "work" do
        put_auth post_path(@post), @user, params: { post: { tag_string: "bbb" } }
        assert_redirected_to post_path(@post)

        @post.reload
        assert_equal("bbb", @post.tag_string)
      end

      should "ignore restricted params" do
        put_auth post_path(@post), @user, params: { post: { last_noted_at: 1.minute.ago } }
        assert_nil(@post.reload.last_noted_at)
      end
    end

    context "revert action" do
      setup do
        as(@user) do
          @post.update(tag_string: "zzz")
        end
      end

      should "work" do
        @version = @post.versions.first
        assert_equal("aaaa", @version.tags)
        put_auth revert_post_path(@post), @user, params: { version_id: @version.id }
        assert_redirected_to post_path(@post)
        @post.reload
        assert_equal("aaaa", @post.tag_string)
      end

      should "not allow reverting to a previous version of another post" do
        as(@user) do
          @post2 = create(:post, uploader_id: @user.id, tag_string: "herp")
        end

        put_auth revert_post_path(@post), @user, params: { version_id: @post2.versions.first.id }
        @post.reload
        assert_not_equal(@post.tag_string, @post2.tag_string)
        assert_response :missing
      end
    end

    context "delete action" do
      should "render" do
        get_auth delete_post_path(@post), @admin
        assert_response :success
      end
    end

    context "destroy action" do
      should "render" do
        post_auth post_path(@post), @admin, params: { reason: "xxx", format: "js", _method: "delete" }
        assert(@post.reload.is_deleted?)
      end

      should "work even if the deleter has flagged the post previously" do
        as(@user) do
          PostFlag.create(post: @post, reason: "aaa", is_resolved: false)
        end
        post_auth post_path(@post), @admin, params: { reason: "xxx", format: "js", _method: "delete" }
        assert(@post.reload.is_deleted?)
      end
    end

    context "undelete action" do
      should "render" do
        as(@user) do
          @post.delete!("test delete")
        end
        assert_difference(-> { PostEvent.count }, 1) do
          post_auth undelete_post_path(@post), @admin, params: { format: :json }
        end

        assert_response :success
        assert_not(@post.reload.is_deleted?)
      end
    end

    context "move_favorites action" do
      setup do
        @admin = create(:admin_user)
      end

      should "render" do
        as(@user) do
          @parent = create(:post)
          @child = create(:post, parent: @parent)
        end
        users = create_list(:user, 2)
        users.each do |u|
          FavoriteManager.add!(user: u, post: @child)
          @child.reload
        end

        post_auth move_favorites_post_path(@child.id), @admin, params: { commit: "Submit" }
        assert_redirected_to(@child)
        perform_enqueued_jobs(only: TransferFavoritesJob)
        @parent.reload
        @child.reload
        as(@admin) do
          assert_equal(users.map(&:id).sort, @parent.favorited_users.map(&:id).sort)
          assert_equal([], @child.favorited_users.map(&:id))
        end
      end
    end

    context "expunge action" do
      should "render" do
        post_auth expunge_post_path(@post), @admin, params: { format: :json }

        assert_response :success
        assert_equal(false, ::Post.exists?(@post.id))
      end
    end

    context "add_to_pool action" do
      setup do
        as(@user) do
          @pool = create(:pool, name: "abc")
        end
      end

      should "add a post to a pool" do
        post_auth add_to_pool_post_path(@post), @user, params: { pool_id: @pool.id, format: :json }
        @pool.reload
        assert_equal([@post.id], @pool.post_ids)
      end

      should "add a post to a pool once and only once" do
        as(@user) { @pool.add!(@post) }
        post_auth add_to_pool_post_path(@post), @user, params: { pool_id: @pool.id, format: :json }
        @pool.reload
        assert_equal([@post.id], @pool.post_ids)
      end
    end

    context "remove_from_pool action" do
      setup do
        as(@user) do
          @pool = create(:pool, name: "abc")
          @pool.add!(@post)
        end
      end

      should "remove a post from a pool" do
        post_auth remove_from_pool_post_path(@post), @user, params: { pool_id: @pool.id, format: :json }
        @pool.reload
        assert_equal([], @pool.post_ids)
      end

      should "do nothing if the post is not a member of the pool" do
        @pool.reload
        as(@user) do
          @pool.remove!(@post)
        end
        post_auth remove_from_pool_post_path(@post), @user, params: { pool_id: @pool.id, format: :json }
        @pool.reload
        assert_equal([], @pool.post_ids)
      end
    end
  end
end
