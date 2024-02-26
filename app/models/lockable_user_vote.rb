# frozen_string_literal: true

class LockableUserVote < UserVote
  self.abstract_class = true

  def self.vote_types
    [%w[Downvote redtext -1], %w[Locked yellowtext 0], %w[Upvote greentext 1]]
  end

  def self.model_type
    super.to_s.delete_prefix("lockable_").to_sym
  end

  def is_locked?
    score == 0
  end

  def vote_type
    if score == 0
      "locked"
    else
      super
    end
  end
end
