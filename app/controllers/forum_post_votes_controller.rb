# frozen_string_literal: true

class ForumPostVotesController < ApplicationController
  respond_to :json
  before_action :member_only
  before_action :moderator_only, only: %i[index]
  before_action :admin_only, only: %i[delete]
  before_action :load_forum_post, except: %i[index delete]
  before_action :validate_forum_post, except: %i[index delete]
  before_action :validate_no_vote_on_own_post, only: %i[create]

  def index
    @forum_post_votes = ForumPostVote.includes(:user, forum_post: [:creator]).search(search_params).paginate(params[:page], limit: 100)
  end

  def create
    @forum_post_vote = @forum_post.votes.create(forum_post_vote_params)
    raise(User::PrivilegeError.new(@forum_post_vote.errors.full_messages.join('; '))) if @forum_post_vote.errors.size > 0
    respond_with(@forum_post_vote) do |fmt|
      fmt.json { render(json: @forum_post_vote, code: 201) }
    end
  end

  def destroy
    VoteManager.forum_post_unvote!(forum_post: @forum_post, user: CurrentUser.user)
  rescue UserVote::Error => e
    render_expected_error(422, e)
  end

  def delete
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
    raise(User::PrivilegeError.new) unless @forum_post.visible?(CurrentUser.user)
    raise(User::PrivilegeError.new) unless @forum_post.votable?
  end

  def validate_no_vote_on_own_post
    raise(User::PrivilegeError, "You cannot vote on your own requests") if @forum_post.creator == CurrentUser.user
  end

  def forum_post_vote_params
    params.fetch(:forum_post_vote, {}).permit(:score)
  end
end
