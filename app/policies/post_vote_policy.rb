# frozen_string_literal: true

class PostVotePolicy < LockableUserVotePolicy
  protected

  def model
    PostVote
  end
end
