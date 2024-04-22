# frozen_string_literal: true

class LockableUserVotePolicy < UserVotePolicy
  def permitted_search_params
    super + %i[is_locked]
  end

  protected

  def model
    LockableUserVote
  end
end
