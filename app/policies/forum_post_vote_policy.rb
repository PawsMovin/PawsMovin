# frozen_string_literal: true

class ForumPostVotePolicy < UserVotePolicy
  protected

  def model
    ForumPostVote
  end
end
