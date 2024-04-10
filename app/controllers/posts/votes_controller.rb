# frozen_string_literal: true

module Posts
  class VotesController < ApplicationController
    respond_to :html, only: %i[index]
    respond_to :json
    skip_before_action :api_check

    def index
      @post_votes = authorize(PostVote).visible(CurrentUser.user).includes(:user).search(search_params(PostVote)).paginate(params[:page], limit: 100)
      respond_with(@post_votes)
    end

    def create
      authorize(PostVote)
      @post = Post.find(params[:post_id])
      @post_vote = VoteManager.vote!(post: @post, user: CurrentUser.user, score: params[:score])
      if @post_vote == :need_unvote && !params[:no_unvote].to_s.truthy?
        VoteManager.unvote!(post: @post, user: CurrentUser.user)
      end
      render(json: { score: @post.score, up: @post.up_score, down: @post.down_score, our_score: @post_vote == :need_unvote ? 0 : @post_vote.score })
    rescue UserVote::Error, ActiveRecord::RecordInvalid => e
      render_expected_error(422, e)
    end

    def destroy
      authorize(PostVote)
      @post = Post.find(params[:post_id])
      VoteManager.unvote!(post: @post, user: CurrentUser.user)
    rescue UserVote::Error => e
      render_expected_error(422, e)
    end

    def lock
      authorize(PostVote)
      ids = params[:ids].split(",")

      ids.each do |id|
        VoteManager.lock!(id)
      end
    end

    def delete
      authorize(PostVote)
      ids = params[:ids].split(",")

      ids.each do |id|
        VoteManager.admin_unvote!(id)
      end
    end
  end
end
