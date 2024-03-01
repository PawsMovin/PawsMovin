# frozen_string_literal: true

require "test_helper"

module Posts
  class VotesControllerTest < ActionDispatch::IntegrationTest
    context "The post vote controller" do
      setup do
        @user = create(:trusted_user)
        as(@user) do
          @post = create(:post)
        end

        @user2 = create(:user)
        CurrentUser.user = @user2
        @admin = create(:admin_user)
      end

      context "create action" do
        should "not allow anonymous users to vote" do
          post post_votes_path(post_id: @post.id), params: { score: 1, format: :json }
          assert_response 403
          assert_equal(0, @post.reload.score)
        end

        should "not allow banned users to vote" do
          @banned = create(:banned_user)
          post_auth post_votes_path(post_id: @post.id), @banned, params: { score: 1, format: :json }
          assert_response 401
          assert_equal(0, @post.reload.score)
        end

        should "increment a post's score if the score is positive" do
          post_auth post_votes_path(post_id: @post.id), @user2, params: { score: 1, format: :json }
          assert_response :success
          @post.reload
          assert_equal(1, @post.score)
        end

        context "for a post that has already been voted on" do
          setup do
            as(@user2) do
              post_auth post_votes_path(post_id: @post.id), @user2, params: { score: 1, format: :json }
            end
          end

          should "fail silently on an error" do
            assert_nothing_raised do
              post_auth post_votes_path(post_id: @post.id), @user2, params: { score: "up", format: :json }
            end
          end
        end
      end

      context "lock action" do
        setup do
          @vote = create(:post_vote, post: @post, user: @user2, score: 1)
        end

        should "lock votes" do
          post_auth lock_post_votes_path, @admin, params: { ids: @vote.id, format: :json }
          assert_response :success

          assert_predicate @vote.reload, :is_locked?
        end

        should "create staff audit log entry" do
          assert_difference("StaffAuditLog.count", 1) do
            post_auth lock_post_votes_path, @admin, params: { ids: @vote.id, format: :json }
            assert_response :success

            assert_predicate @vote.reload, :is_locked?
          end

          log = StaffAuditLog.last
          assert_equal "post_vote_lock", log.action
          assert_equal @post.id, log.post_id
          assert_equal 1, log.vote
          assert_equal @user2.id, log.voter_id
        end
      end

      context "delete action" do
        setup do
          @vote = create(:post_vote, post: @post, user: @user2, score: 1)
        end

        should "delete votes" do
          post_auth delete_post_votes_path, @admin, params: { ids: @vote.id, format: :json }
          assert_response :success

          assert_raises(ActiveRecord::RecordNotFound) do
            @vote.reload
          end
        end

        should "create a staff audit log entry" do
          assert_difference("StaffAuditLog.count", 1) do
            post_auth delete_post_votes_path, @admin, params: { ids: @vote.id, format: :json }
            assert_response :success

            assert_raises(ActiveRecord::RecordNotFound) do
              @vote.reload
            end
          end

          log = StaffAuditLog.last
          assert_equal "post_vote_delete", log.action
          assert_equal @post.id, log.post_id
          assert_equal 1, log.vote
          assert_equal @user2.id, log.voter_id
        end
      end
    end
  end
end
