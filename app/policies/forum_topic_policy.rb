# frozen_string_literal: true

class ForumTopicPolicy < ApplicationPolicy
  def show?
    min_level?
  end

  def update?
    min_level? && (!record.is_a?(ForumTopic) || record.editable_by?(user))
  end

  def destroy?
    min_level? && (!record.is_a?(ForumTopic) || record.can_delete?(user))
  end

  def hide?
    min_level? && (!record.is_a?(ForumTopic) || record.can_hide?(user))
  end

  def unhide?
    user.is_moderator? && min_level? && (!record.is_a?(ForumTopic) || record.can_hide?(user))
  end

  def lock?
    min_level? && user.is_moderator?
  end

  def unlock?
    min_level? && user.is_moderator?
  end

  def sticky?
    min_level? && user.is_moderator?
  end

  def unsticky?
    min_level? && user.is_moderator?
  end

  def subscribe?
    min_level?
  end

  def unsubscribe?
    min_level?
  end

  def confirm_move?
    move?
  end

  def move?
    min_level? && user.is_moderator?
  end

  def mark_all_as_read?
    true
  end

  def min_level?
    !record.is_a?(ForumTopic) || record.visible?(user)
  end

  def permitted_attributes
    attr = [:title, :category_id, { original_post_attributes: %i[id body] }]
    attr += %i[is_sticky is_locked] if user.is_moderator?
    attr
  end

  def permitted_search_params
    super + %i[title title_matches category_id is_sticky is_locked is_hidden order]
  end
end
