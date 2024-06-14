# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def index?
    unbanned?
  end

  def show?
    unbanned? && (record.nil? || record.user_id == user.id)
  end

  def destroy?
    unbanned? && (record.nil? || record.user_id == user.id)
  end

  def mark_as_read?
    unbanned? && (record.nil? || record.user_id == user.id)
  end

  def mark_all_as_read?
    unbanned?
  end
end
