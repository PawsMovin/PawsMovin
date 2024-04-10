# frozen_string_literal: true

class ApiKeyPolicy < ApplicationPolicy
  def index?
    unbanned?
  end

  def permitted_attributes
    [:name, :permitted_ip_addresses, { permissions: [] }]
  end

  def permitted_search_params
    super + %i[user_id user_name]
  end
end
