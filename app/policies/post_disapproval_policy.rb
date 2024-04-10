# frozen_string_literal: true

class PostDisapprovalPolicy < ApplicationPolicy
  def index?
    approver?
  end

  def create?
    approver?
  end

  def permitted_attributes
    %i[post_id reason message]
  end
end
