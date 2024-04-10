# frozen_string_literal: true

class ForumCategoryPolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end

  def reorder?
    user.is_admin?
  end

  def permitted_attributes
    %i[name can_create can_reply can_view order]
  end
end
