# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def revert?
    update?
  end

  def permitted_attributes
    %i[x y width height body]
  end

  def permitted_attributes_for_create
    super + %i[post_id html_id]
  end

  def permitted_search_params
    super + %i[body_matches is_active post_id post_tags_match post_note_updater_id post_note_updater_name creator_id creator_name]
  end
end
