# frozen_string_literal: true

class UserNameChangeRequestPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def show?
    unbanned? && (record.user_id == user.id || user.is_moderator?)
  end

  def permitted_attributes
    %i[desired_name change_reason]
  end
end
