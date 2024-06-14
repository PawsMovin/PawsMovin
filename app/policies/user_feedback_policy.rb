# frozen_string_literal: true

class UserFeedbackPolicy < ApplicationPolicy
  def create?
    user.is_moderator?
  end

  def update?
    user.is_moderator? && (record.nil? || record.editable_by?(user))
  end

  def destroy?
    user.is_moderator? && (record.nil? || record.deletable_by?(user))
  end

  def permitted_attributes
    %i[body category]
  end

  def permitted_attributes_for_create
    super + %i[user_id user_name]
  end

  def permitted_attributes_for_update
    super + %i[send_update_notification]
  end

  def permitted_search_params
    super + %i[body_matches user_id user_name creator_id creator_name category order]
  end
end
