# frozen_string_literal: true

class UploadWhitelistPolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end

  def is_allowed?
    unbanned?
  end

  def permitted_attributes
    %i[allowed pattern reason note hidden]
  end

  def permitted_search_params
    super + %i[allowed order pattern note reason]
  end
end
