# frozen_string_literal: true

class RulePolicy < ApplicationPolicy
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
    reorder?
  end

  def reorder?
    user.is_admin?
  end

  def builder?
    user.is_moderator?
  end

  def permitted_attributes
    %i[name description category_id anchor order]
  end
end
