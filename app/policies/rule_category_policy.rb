# frozen_string_literal: true

class RuleCategoryPolicy < ApplicationPolicy
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

  def permitted_attributes
    %i[name anchor]
  end
end
