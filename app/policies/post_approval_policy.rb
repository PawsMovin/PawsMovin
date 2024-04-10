# frozen_string_literal: true

# record: Post
class PostApprovalPolicy < ApplicationPolicy
  def create?
    approver?
  end

  def destroy?
    approver?
  end
end
