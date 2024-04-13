# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def custom_style?
    unbanned?
  end

  def upload_limit?
    unbanned?
  end

  def permitted_attributes
    %i[
      password old_password password_confirmation
      comment_threshold default_image_size favorite_tags blacklisted_tags
      time_zone per_page custom_style
    ] + User::Preferences.settable_list + [dmail_filter_attributes: %i[id words]]
  end

  def permitted_attributes_for_create
    super + %i[name email]
  end

  def permitted_attributes_for_update
    attr = super + %i[enable_hover_zoom_form]
    attr += %i[profile_about profile_artinfo avatar_id] if unbanned? # Prevent editing when banned
    attr += %i[enable_compact_uploader] if CurrentUser.post_active_count >= PawsMovin.config.compact_uploader_minimum_posts
    attr
  end

  def permitted_search_params
    params = super + %i[name_matches about_me avatar_id level min_level max_level unrestricted_uploads can_approve_posts order]
    params += %i[ip_addr] if can_search_ip_addr?
    params += %i[email_matches] if CurrentUser.is_admin?
    params
  end
end
