# frozen_string_literal: true

require "test_helper"

module ForumPosts
  class VotesControllerTest < ActionDispatch::IntegrationTest
    context "The forum post votes controller" do
      setup do
        @user = create(:user)
        as(@user) do
          @topic = create(:forum_topic, original_post_attributes: { body: "test" })
          @forum_post = @topic.original_post
          create(:tag_alias, forum_post: @forum_post)
        end

        @user2 = create(:user)
        @admin = create(:admin_user)
        CurrentUser.user = @user2
      end

      context "show action" do
        should "render" do
          get_auth url_for(controller: "forum_posts/votes", action: "index", only_path: true), @admin
          assert_response :success
        end

        context "members" do
          should "render" do
            get_auth url_for(controller: "forum_posts/votes", action: "index", only_path: true), @user2
            assert_response :success
          end

          should "only list own votes" do
            create(:forum_post_vote, forum_post: @forum_post, user: @user2, score: -1)
            create(:forum_post_vote, forum_post: @forum_post, user: @admin, score: 1)

            get_auth url_for(controller: "forum_posts/votes", action: "index", format: "json", only_path: true), @user2
            assert_response :success
            assert_equal(1, response.parsed_body.length)
            assert_equal(@user2.id, response.parsed_body[0]["user_id"])
          end
        end
      end

      context "delete action" do
        setup do
          @vote = create(:forum_post_vote, forum_post: @forum_post, user: @user2, score: -1)
        end

        should "delete votes" do
          post_auth delete_forum_post_votes_path, @admin, params: { ids: @vote.id, format: :json }
          assert_response :success

          assert_raises(ActiveRecord::RecordNotFound) do
            @vote.reload
          end
        end

        should "create a staff audit log entry" do
          assert_difference("StaffAuditLog.count", 1) do
            post_auth delete_forum_post_votes_path, @admin, params: { ids: @vote.id, format: :json }
            assert_response :success

            assert_raises(ActiveRecord::RecordNotFound) do
              @vote.reload
            end
          end

          log = StaffAuditLog.last
          assert_equal "forum_post_vote_delete", log.action
          assert_equal @forum_post.id, log.forum_post_id
          assert_equal(-1, log.vote)
          assert_equal @user2.id, log.voter_id
        end
      end
    end
  end
end
