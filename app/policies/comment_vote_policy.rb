# frozen_string_literal: true

class CommentVotePolicy < LockableUserVotePolicy
  protected

  def model
    CommentVote
  end
end
