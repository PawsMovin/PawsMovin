# frozen_string_literal: true

class ForumPostPolicy < ApplicationPolicy
  def show?
    min_level?
  end

  def create?
    min_level?
  end

  def update?
    min_level? && (!record.is_a?(ForumPost) || record.editable_by?(user))
  end

  def destroy?
    min_level? && (!record.is_a?(ForumPost) || record.can_delete?(user))
  end

  def hide?
    min_level? && (!record.is_a?(ForumPost) || record.can_hide?(user))
  end

  def unhide?
    user.is_moderator? && min_level? && (!record.is_a?(ForumPost) || record.can_hide?(user))
  end

  def warning?
    user.is_moderator?
  end

  def min_level?
    return true unless record.is_a?(ForumPost) && record.topic.is_a?(ForumTopic)
    return false unless record.topic.visible?(user)
    return false if record.topic.is_hidden? && !record.topic.can_hide?(user)
    return false if record.is_hidden? && !record.can_hide?(user)
    true
  end

  def permitted_attributes
    %i[body]
  end

  def permitted_attributes_for_create
    super + %i[topic_id]
  end

  def permitted_search_params
    super + %i[creator_id creator_name topic_id topic_title_matches body_matches topic_category_id is_hidden order]
  end
end
