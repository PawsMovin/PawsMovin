# frozen_string_literal: true

class StuckDnpPolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def permitted_attributes
    %i[query]
  end
end
