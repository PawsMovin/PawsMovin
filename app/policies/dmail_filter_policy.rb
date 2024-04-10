# frozen_string_literal: true

class DmailFilterPolicy < ApplicationPolicy
  def show?
    logged_in?
  end

  def update?
    logged_in? && (!record.is_a?(DmailFilter) || record.owner_id == user.id)
  end

  def permitted_attributes
    %i[words]
  end
end
