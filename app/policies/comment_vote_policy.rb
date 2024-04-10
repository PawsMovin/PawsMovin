# frozen_string_literal: true

class CommentVotePolicy < UserVotePolicy
  protected

  def model
    CommentVote
  end
end
