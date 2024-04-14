# frozen_string_literal: true

class AvoidPostingPolicy < ApplicationPolicy
  def create?
    user.can_edit_avoid_posting_entries?
  end

  def update?
    user.can_edit_avoid_posting_entries?
  end

  def destroy?
    user.can_edit_avoid_posting_entries?
  end

  def deactivate?
    user.can_edit_avoid_posting_entries?
  end

  def reactivate?
    user.can_edit_avoid_posting_entries?
  end

  def permitted_attributes
    %i[artist_name details staff_notes is_active]
  end

  def permitted_attributes_for_update
    super + %i[rename_artist]
  end

  def permitted_search_params
    params = super + %i[creator_name creator_id any_name_matches artist_name artist_id any_other_name_matches details is_active]
    params += %i[staff_notes] if user.is_staff?
    params += %i[creator_ip_addr] if can_search_ip_addr?
    params
  end
end
