# frozen_string_literal: true

require "test_helper"

class CommentVotesControllerTest < ActionDispatch::IntegrationTest
  context "A comment votes controller" do
    setup do
      @user = create(:user)
      @post = create(:post, uploader: @user)
      as(@user) do
        @comment = create(:comment, post: @post)
      end

      @user2 = create(:user)
      @admin = create(:admin_user)
      CurrentUser.user = @user2
    end

    context "create action" do
      should "create a vote" do
        assert_difference(-> { CommentVote.count }, 1) do
          post_auth comment_votes_path(@comment), @user2, params: { score: -1, format: :json }
          assert_response :success
        end
      end

      should "unvote when the vote already exists" do
        create(:comment_vote, comment: @comment, user: @user2, score: -1)
        assert_difference(-> { CommentVote.count }, -1) do
          post_auth comment_votes_path(@comment), @user2, params: { score: -1, format: :json }
          assert_response :success
        end
      end
    end

    context "lock action" do
      setup do
        @vote = create(:comment_vote, comment: @comment, user: @user2, score: -1)
      end

      should "lock votes" do
        post_auth lock_comment_votes_path, @admin, params: { ids: @vote.id, format: :json }
        assert_response :success

        assert_predicate @vote.reload, :is_locked?
      end

      should "create staff audit log entry" do
        assert_difference("StaffAuditLog.count", 1) do
          post_auth lock_comment_votes_path, @admin, params: { ids: @vote.id, format: :json }
          assert_response :success

          assert_predicate @vote.reload, :is_locked?
        end

        log = StaffAuditLog.last
        assert_equal "comment_vote_lock", log.action
        assert_equal @comment.id, log.comment_id
        assert_equal(-1, log.vote)
        assert_equal @user2.id, log.voter_id
      end
    end

    context "delete action" do
      setup do
        @vote = create(:comment_vote, comment: @comment, user: @user2, score: -1)
      end

      should "delete votes" do
        post_auth delete_comment_votes_path, @admin, params: { ids: @vote.id, format: :json }
        assert_response :success

        assert_raises(ActiveRecord::RecordNotFound) do
          @vote.reload
        end
      end

      should "create a staff audit log entry" do
        assert_difference("StaffAuditLog.count", 1) do
          post_auth delete_comment_votes_path, @admin, params: { ids: @vote.id, format: :json }
          assert_response :success

          assert_raises(ActiveRecord::RecordNotFound) do
            @vote.reload
          end
        end

        log = StaffAuditLog.last
        assert_equal "comment_vote_delete", log.action
        assert_equal @comment.id, log.comment_id
        assert_equal(-1, log.vote)
        assert_equal @user2.id, log.voter_id
      end
    end
  end
end
