# frozen_string_literal: true

class UserDeletionPolicy < ApplicationPolicy
  def show?
    logged_in?
  end

  def destroy?
    logged_in?
  end
end
