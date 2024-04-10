# frozen_string_literal: true

module Moderator
  class IpAddrSearchPolicy < ApplicationPolicy
    def index?
      user.is_admin?
    end

    def export?
      user.is_admin?
    end

    def permitted_search_params
      super + %i[with_history user_id user_name ip_addr add_ip_mask]
    end
  end
end
