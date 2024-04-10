# frozen_string_literal: true

class TagImplicationPolicy < ApplicationPolicy
  def create?
    # record: TagImplicationRequest
    unbanned?
  end

  def update?
    user.can_manage_aibur?
  end

  def approve?
    user.can_manage_aibur?
  end

  def permitted_attributes_for_create
    params = %i[antecedent_name consequent_name reason forum_topic_id]
    params += %i[skip_forum] if user.is_admin?
    params
  end

  def permitted_attributes_for_update
    %i[antecedent_name consequent_name]
  end
end
