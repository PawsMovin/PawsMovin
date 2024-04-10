# frozen_string_literal: true

class UserRevertPolicy < ApplicationPolicy
  def create?
    user.is_moderator?
  end
end
