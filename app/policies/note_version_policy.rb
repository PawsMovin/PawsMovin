# frozen_string_literal: true

class NoteVersionPolicy < ApplicationPolicy
  def permitted_search_params
    params = super + %i[updater_id updater_name post_id note_id is_active body_matches]
    params += %i[ip_addr] if can_search_ip_addr?
    params
  end
end
