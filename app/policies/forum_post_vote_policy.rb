# frozen_string_literal: true

class ForumPostVotePolicy < UserVotePolicy
  def create?
    return unbanned? unless record.is_a?(ForumPost)
    policy(record).min_level? && unbanned?
  end

  protected

  def model
    ForumPostVote
  end
end
