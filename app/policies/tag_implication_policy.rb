# frozen_string_literal: true

class TagImplicationPolicy < ApplicationPolicy
  def create?
    # record: TagImplicationRequest
    unbanned?
  end

  def destroy?
    return unbanned? unless record.is_a?(TagImplication)
    unbanned? && record.rejectable_by?(user)
  end

  def update?
    return unbanned? unless record.is_a?(TagImplication)
    unbanned? && record.editable_by?(user)
  end

  def approve?
    return unbanned? && user.can_manage_aibur? unless record.is_a?(TagImplication)
    unbanned? && record.approvable_by?(user)
  end

  def permitted_attributes
    %i[antecedent_name consequent_name]
  end

  def permitted_attributes_for_create
    params = super + %i[reason forum_topic_id]
    params += %i[skip_forum] if user.is_admin?
    params
  end

  def permitted_search_params
    super + %i[name_matches antecedent_name consequent_name status antecedent_tag_category consequent_tag_category creator_id creator_name approver_id approver_name]
  end
end
