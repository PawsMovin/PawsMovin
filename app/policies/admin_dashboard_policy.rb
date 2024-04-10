# frozen_string_literal: true

class AdminDashboardPolicy < ApplicationPolicy
  def show?
    user.is_admin?
  end
end
