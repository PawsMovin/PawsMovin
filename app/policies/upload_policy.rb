# frozen_string_literal: true

class UploadPolicy < ApplicationPolicy
  def index?
    user.is_janitor?
  end

  def permitted_attributes
    attr = %i[file direct_url source tag_string rating parent_id description description]

    attr += %i[as_pending] if user.unrestricted_uploads?
    attr += %i[locked_rating] if user.is_trusted?
    attr += %i[locked_tags] if user.is_admin?
    attr
  end

  def permitted_search_params
    super + %i[uploader_id uploader_name source source_matches rating parent_id post_id has_post post_tags_match status backtrace tag_string]
  end
end
