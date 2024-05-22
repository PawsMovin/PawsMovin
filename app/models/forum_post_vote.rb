# frozen_string_literal: true

class ForumPostVote < UserVote
  belongs_to :forum_post
  validates :score, inclusion: { in: [-1, 0, 1], message: "must be 1, 0 or -1" }
  validates :user_id, uniqueness: { scope: :forum_post_id }
  validate :validate_user_is_not_limited, on: :create
  scope :by, ->(user_id) { where(user_id: user_id) }
  scope :excluding_user, ->(user_id) { where.not(user_id: user_id) }

  def self.vote_types
    [%w[Downvote -1 redtext], %w[Meh 0 yellowtext], %w[Upvote 1 greentext]]
  end

  def self.model_creator_column
    :creator
  end

  def user_name
    if association(:user).loaded?
      return user&.name || "Anonymous"
    end
    User.id_to_name(user_id)
  end

  def method_attributes
    super + %i[user_name]
  end

  def validate_user_is_not_limited
    allowed = user.can_forum_vote_with_reason
    if allowed != true
      errors.add(:user, User.throttle_reason(allowed))
      return false
    end
    true
  end

  def is_meh?
    score == 0
  end

  def vote_type
    if score == 0
      "locked"
    else
      super
    end
  end

  def fa_class
    if score == 1
      "fa-thumbs-up"
    elsif score == -1
      "fa-thumbs-down"
    else
      "fa-face-meh"
    end
  end

  def self.model_type
    model_name.singular.delete_suffix("_vote").to_sym
  end
end
