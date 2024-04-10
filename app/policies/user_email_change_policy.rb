# frozen_string_literal: true

class UserEmailChangePolicy < ApplicationPolicy
  def create?
    logged_in?
  end
end
