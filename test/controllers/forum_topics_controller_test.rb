# frozen_string_literal: true

require "test_helper"

class ForumTopicsControllerTest < ActionDispatch::IntegrationTest
  context "The forum topics controller" do
    setup do
      @user = create(:user)
      @other_user = create(:user)
      @mod = create(:moderator_user)
      @admin = create(:admin_user)

      as(@user) do
        @forum_topic = create(:forum_topic, title: "my forum topic", original_post_attributes: { body: "xxx" })
      end
    end

    context "show action" do
      should "render" do
        get forum_topic_path(@forum_topic)
        assert_response :success
      end

      should "record a topic visit for html requests" do
        get_auth forum_topic_path(@forum_topic), @user
        @user.reload
        assert_not_nil(@user.last_forum_read_at)
      end

      should "not record a topic visit for non-html requests" do
        get_auth forum_topic_path(@forum_topic), @user, params: { format: :json }
        @user.reload
        assert_nil(@user.last_forum_read_at)
      end
    end

    context "index action" do
      setup do
        as(@user) do
          @topic1 = create(:forum_topic, title: "a", is_sticky: true, original_post_attributes: { body: "xxx" })
          @topic2 = create(:forum_topic, title: "b", original_post_attributes: { body: "xxx" })
        end
      end

      should "list all forum topics" do
        get forum_topics_path
        assert_response :success
      end

      should "not list stickied topics first for JSON responses" do
        get forum_topics_path, params: { format: :json }
        forum_topics = response.parsed_body
        assert_equal([@topic2.id, @topic1.id, @forum_topic.id], forum_topics.pluck("id"))
      end

      context "with search conditions" do
        should "list all matching forum topics" do
          get forum_topics_path, params: { search: { title_matches: "forum" } }
          assert_response :success
          assert_select "a.forum-post-link", @forum_topic.title
          assert_select "a.forum-post-link", { count: 0, text: @topic1.title }
          assert_select "a.forum-post-link", { count: 0, text: @topic2.title }
        end

        should "list nothing for when the search matches nothing" do
          get forum_topics_path, params: { search: { title_matches: "bababa" } }
          assert_response :success
          assert_select "a.forum-post-link", { count: 0, text: @forum_topic.title }
          assert_select "a.forum-post-link", { count: 0, text: @topic1.title }
          assert_select "a.forum-post-link", { count: 0, text: @topic2.title }
        end
      end
    end

    context "edit action" do
      should "render if the editor is the creator of the topic" do
        get_auth edit_forum_topic_path(@forum_topic), @user
        assert_response :success
      end

      should "render if the editor is an admin" do
        get_auth edit_forum_topic_path(@forum_topic), @admin
        assert_response :success
      end

      should "fail if the editor is not the creator of the topic and is not an admin" do
        get_auth edit_forum_topic_path(@forum_topic), @other_user
        assert_response(403)
      end
    end

    context "new action" do
      should "render" do
        get_auth new_forum_topic_path, @user
        assert_response :success
      end
    end

    context "create action" do
      should "create a new forum topic and post" do
        assert_difference(["ForumPost.count", "ForumTopic.count"], 1) do
          post_auth forum_topics_path, @user, params: { forum_topic: { title: "bababa", category_id: PawsMovin.config.alias_implication_forum_category, original_post_attributes: { body: "xaxaxa" } } }
        end

        forum_topic = ForumTopic.last
        assert_redirected_to(forum_topic_path(forum_topic))
      end

      should "fail with expected error if invalid category_id is provided" do
        post_auth forum_topics_path, @user, params: { forum_topic: { title: "bababa", category_id: 0, original_post_attributes: { body: "xaxaxa" } }, format: :json }

        assert_response :unprocessable_entity
        assert_includes(@response.parsed_body.dig("errors", "category"), "is invalid")
      end

      should "cause the unread indicator to show" do
        @other_user.update(last_forum_read_at: Time.now)
        get_auth posts_path, @other_user
        assert_select "#nav-forum.forum-updated", false

        post_auth forum_topics_path, @user, params: { forum_topic: { title: "bababa", category_id: PawsMovin.config.alias_implication_forum_category, original_post_attributes: { body: "xaxaxa" } } }

        get_auth posts_path, @other_user
        assert_select "#nav-forum.forum-updated"
      end
    end

    context "destroy action" do
      setup do
        as(@user) do
          @post = create(:forum_post, topic_id: @forum_topic.id)
        end
      end

      should "destroy the topic and any associated posts" do
        delete_auth forum_topic_path(@forum_topic), @admin
        assert_redirected_to(forum_topics_path)
      end
    end

    context "hide action" do
      should "hide the topic" do
        put_auth hide_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert(@forum_topic.is_hidden?)
      end
    end

    context "unhide action" do
      setup do
        @forum_topic.update_column(:is_hidden, true)
      end

      should "unhide the topic" do
        put_auth unhide_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert_not(@forum_topic.is_hidden?)
      end
    end

    context "lock action" do
      should "lock the topic" do
        put_auth lock_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert(@forum_topic.is_locked?)
      end
    end

    context "unlock action" do
      setup do
        @forum_topic.update_column(:is_locked, true)
      end

      should "unlock the topic" do
        put_auth unlock_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert_not(@forum_topic.is_locked?)
      end
    end

    context "sticky action" do
      should "sticky the topic" do
        put_auth sticky_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert(@forum_topic.is_sticky?)
      end
    end

    context "unsticky action" do
      setup do
        @forum_topic.update_column(:is_sticky, true)
      end

      should "unsticky the topic" do
        put_auth unsticky_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert_not(@forum_topic.is_sticky?)
      end
    end

    context "move action" do
      setup do
        @category = @forum_topic.category
        as(@admin) do
          @category2 = create(:forum_category)
        end
      end

      should "move the topic" do
        post_auth move_forum_topic_path(@forum_topic), @mod, params: { forum_topic: { category_id: @category2.id } }
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert_equal(@category2.id, @forum_topic.category.id)
      end

      should "not move the topic if the mover cannot create within the new category" do
        @category2.update_column(:can_create, @mod.level + 1)
        post_auth move_forum_topic_path(@forum_topic), @mod, params: { forum_topic: { category_id: @category2.id }, format: :json }
        assert_response(:forbidden)
        assert_equal("You cannot move topics into categories you cannot create within.", @response.parsed_body["message"])
        @forum_topic.reload
        assert_equal(@category.id, @forum_topic.category.id)
      end

      should "not move the topic if the topic creator cannot create within the new category" do
        @category2.update_column(:can_create, @forum_topic.creator.level + 1)
        post_auth move_forum_topic_path(@forum_topic), @mod, params: { forum_topic: { category_id: @category2.id }, format: :json }
        assert_response(:forbidden)
        assert_equal("You cannot move topics into categories the topic creator cannot create within.", @response.parsed_body["message"])
        @forum_topic.reload
        assert_equal(@category.id, @forum_topic.category.id)
      end
    end

    context "subscribe action" do
      setup do
        @status = create(:forum_topic_status, forum_topic: @forum_topic, user: @user, mute: true)
      end

      should "ensure mute=false" do
        assert_no_difference("ForumTopicStatus.count") do
          put_auth subscribe_forum_topic_path(@forum_topic), @user
        end
        @status.reload
        assert_equal(false, @status.mute)
        assert_equal(true, @status.subscription)
      end

      should "not create a new status entry if one already exists" do
        assert_no_difference("ForumTopicStatus.count") do
          put_auth subscribe_forum_topic_path(@forum_topic), @user
        end
      end
    end

    context "mute action" do
      setup do
        @status = create(:forum_topic_status, forum_topic: @forum_topic, user: @user, subscription: true)
      end

      should "ensure subscription=false" do
        assert_no_difference("ForumTopicStatus.count") do
          put_auth mute_forum_topic_path(@forum_topic), @user, params: { _method: "PUT" }
        end
        @status.reload
        assert_equal(false, @status.subscription)
        assert_equal(true, @status.mute)
      end

      should "not create a new status entry if one already exists" do
        assert_no_difference("ForumTopicStatus.count") do
          put_auth mute_forum_topic_path(@forum_topic), @user, params: { _method: "PUT" }
        end
      end
    end
  end
end
