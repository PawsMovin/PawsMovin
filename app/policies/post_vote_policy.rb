# frozen_string_literal: true

class PostVotePolicy < UserVotePolicy
  protected

  def model
    PostVote
  end
end
