# frozen_string_literal: true

module ForumPosts
  class VotesController < ApplicationController
    respond_to :html, only: %i[index]
    respond_to :json
    before_action :load_forum_post, except: %i[index delete]
    before_action :validate_forum_post, except: %i[index delete]
    before_action :validate_no_vote_on_own_post, only: %i[create]

    def index
      @forum_post_votes = authorize(ForumPostVote).visible(CurrentUser.user).includes(:user, forum_post: %i[creator]).search(search_params(ForumPostVote)).paginate(params[:page], limit: 100)
      respond_with(@forum_post_votes)
    end

    def create
      authorize(ForumPostVote)
      @forum_post_vote = @forum_post.votes.create(permitted_attributes(ForumPostVote))
      raise(User::PrivilegeError, @forum_post_vote.errors.full_messages.join("; ")) unless @forum_post_vote.errors.empty?
      respond_with(@forum_post_vote) do |fmt|
        fmt.json { render(json: @forum_post_vote, code: 201) }
      end
    end

    def destroy
      authorize(ForumPostVote)
      VoteManager.forum_post_unvote!(forum_post: @forum_post, user: CurrentUser.user)
    rescue UserVote::Error => e
      render_expected_error(422, e)
    end

    def delete
      authorize(ForumPostVote)
      ids = params[:ids].split(",")

      ids.each do |id|
        VoteManager.admin_forum_post_unvote!(id)
      end
    end

    private

    def load_forum_post
      @forum_post = ForumPost.find(params[:forum_post_id])
    end

    def validate_forum_post
      raise(User::PrivilegeError) unless @forum_post.visible?(CurrentUser.user)
      raise(User::PrivilegeError) unless @forum_post.votable?
    end

    def validate_no_vote_on_own_post
      raise(User::PrivilegeError, "You cannot vote on your own requests") if @forum_post.creator == CurrentUser.user
    end
  end
end
