# frozen_string_literal: true

class HelpPagePolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end

  def permitted_attributes
    %i[name wiki_page related title]
  end
end
