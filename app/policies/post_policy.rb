# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def show_seq?
    show?
  end

  def random?
    show?
  end

  def update_iqdb?
    unbanned? && user.is_admin?
  end

  def expunge?
    unbanned? && user.is_approver? && user.is_admin?
  end

  def revert?
    unbanned?
  end

  def copy_notes?
    unbanned?
  end

  def mark_as_translated?
    unbanned?
  end

  def regenerate_thumbnails?
    unbanned? && user.is_janitor?
  end

  def regenerate_videos?
    unbanned? && user.is_janitor?
  end

  def uploaders?
    unbanned? && user.is_janitor?
  end

  def destroy?
    unbanned? && user.is_janitor?
  end

  def undelete?
    unbanned? && user.is_approver?
  end

  def confirm_move_favorites?
    move_favorites?
  end

  def move_favorites?
    unbanned? && user.is_approver?
  end

  def approve?
    unbanned? && user.is_approver?
  end

  def unapprove?
    unbanned? && user.is_approver?
  end

  def add_to_pool?
    unbanned?
  end

  def remove_from_pool?
    unbanned?
  end

  def favorites?
    unbanned?
  end

  def deleted?
    true
  end

  def change_locked_tags?
    user.is_admin?
  end

  def permitted_attributes_for_update
    attr = %i[
      tag_string old_tag_string
      tag_string_diff source_diff
      source old_source
      parent_id old_parent_id
      description old_description
      rating old_rating
      edit_reason
    ]
    attr += %i[is_rating_locked] if user.is_trusted?
    attr += %i[is_note_locked bg_color] if user.is_janitor?
    attr += %i[is_comment_locked] if user.is_moderator?
    attr += %i[is_status_locked is_comment_disabled locked_tags hide_from_anonymous hide_from_search_engines] if user.is_admin?
    attr
  end

  # due to how internals work (inline editing), this is needed
  def permitted_attributes_for_show
    permitted_attributes_for_update
  end

  def permitted_attributes_for_mark_as_translated
    %i[]
  end

  def permitted_search_params_for_uploaders
    permitted_search_params + %i[user_id user_name]
  end
end
