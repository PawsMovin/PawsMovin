# frozen_string_literal: true

class QuickRulePolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end

  def order?
    user.is_admin?
  end

  def reorder?
    user.is_admin?
  end

  def permitted_attributes
    %i[header reason rule_id order]
  end
end
