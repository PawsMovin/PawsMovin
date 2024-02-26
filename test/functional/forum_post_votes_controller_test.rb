# frozen_string_literal: true

require "test_helper"

class ForumPostVotesControllerTest < ActionDispatch::IntegrationTest
  context "A forum post votes controller" do
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
