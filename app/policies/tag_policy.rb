# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def meta_search?
    index?
  end

  def preview?
    unbanned?
  end

  def update?
    return false if record && !record.category_editable_by?(user)
    unbanned?
  end

  def correct?
    user.is_janitor?
  end

  def permitted_attributes
    attr = %i[category]
    attr += %i[is_locked] if user.is_admin?
    attr
  end

  def permitted_search_params
    super + %i[fuzzy_name_matches name_matches name category hide_empty has_wiki has_artist is_locked]
  end
end
