# frozen_string_literal: true

class ModeratorDashboardPolicy < ApplicationPolicy
  def show?
    user.is_moderator?
  end
end
