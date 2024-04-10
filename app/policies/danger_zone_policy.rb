# frozen_string_literal: true

class DangerZonePolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end
end
