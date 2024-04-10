# frozen_string_literal: true

module Comments
  class VotesController < ApplicationController
    respond_to :html, only: %i[index]
    respond_to :json
    skip_before_action :api_check

    def index
      @comment_votes = authorize(CommentVote).visible(CurrentUser.user).includes(:user, comment: [:creator]).search(search_params(CommentVote)).paginate(params[:page], limit: 100)
      respond_with(@comment_votes)
    end

    def create
      authorize(CommentVote)
      @comment = Comment.find(params[:comment_id])
      @comment_vote = VoteManager.comment_vote!(comment: @comment, user: CurrentUser.user, score: permitted_attributes(CommentVote)[:score])
      if @comment_vote == :need_unvote && !params[:no_unvote].to_s.truthy?
        VoteManager.comment_unvote!(comment: @comment, user: CurrentUser.user)
      end
      @comment.reload
      render(json: { score: @comment.score, our_score: @comment_vote == :need_unvote ? 0 : @comment_vote.score })
    rescue UserVote::Error, ActiveRecord::RecordInvalid => e
      render_expected_error(422, e)
    end

    def destroy
      authorize(CommentVote)
      @comment = Comment.find(params[:comment_id])
      VoteManager.comment_unvote!(comment: @comment, user: CurrentUser.user)
    rescue UserVote::Error => e
      render_expected_error(422, e)
    end

    def lock
      authorize(CommentVote)
      ids = params[:ids].split(",")

      ids.each do |id|
        VoteManager.comment_lock!(id)
      end
    end

    def delete
      authorize(CommentVote)
      ids = params[:ids].split(",")

      ids.each do |id|
        VoteManager.admin_comment_unvote!(id)
      end
    end
  end
end
