# frozen_string_literal: true

class AvoidPostingVersionPolicy < ApplicationPolicy
  def permitted_search_params
    params = super + %i[updater_name updater_id any_name_matches artist_name artist_id any_other_name_matches is_active]
    params += %i[updater_ip_addr] if can_search_ip_addr?
    params
  end
end
