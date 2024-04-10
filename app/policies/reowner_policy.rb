# frozen_string_literal: true

class ReownerPolicy < ApplicationPolicy
  def new?
    user.is_owner?
  end

  def create?
    user.is_owner?
  end

  def permitted_attributes
    %i[old_owner search new_owner]
  end
end
