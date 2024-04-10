# frozen_string_literal: true

class WikiPagePolicy < ApplicationPolicy
  def show_or_new?
    index?
  end

  def destroy?
    user.is_admin?
  end

  def revert?
    update?
  end

  def permitted_attributes
    attr = %i[body skip_post_count_rename_check edit_reason]
    attr += %i[parent] if user.is_trusted?
    attr += %i[is_locked] if user.is_janitor?
    attr
  end

  def permitted_attributes_for_create
    super + %i[title]
  end

  def permitted_attributes_for_update
    attr = super
    attr += %i[title] if user.is_janitor?
    attr
  end
end
