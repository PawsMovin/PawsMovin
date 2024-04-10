# frozen_string_literal: true

class PostReplacementRejectionReasonPolicy < ApplicationPolicy
  def index?
    approver?
  end

  def create?
    approver? && user.is_admin?
  end

  def update?
    approver? && user.is_admin?
  end

  def destroy?
    approver? && user.is_admin?
  end

  def reorder?
    approver? && user.is_admin?
  end

  def permitted_attributes
    %i[reason order]
  end
end
