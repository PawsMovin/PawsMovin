# frozen_string_literal: true

class EditHistoryPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def diff?
    index?
  end

  def permitted_search_params
    params = super + %i[versionable_type versionable_id edit_type user_id user_name]
    params += %i[ip_addr] if can_search_ip_addr?
    params
  end
end
