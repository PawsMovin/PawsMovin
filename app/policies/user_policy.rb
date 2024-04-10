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
      time_zone per_page custom_style description_collapsed_initially hide_comments

      receive_email_notifications enable_keyboard_navigation
      enable_privacy_mode disable_user_dmails show_post_statistics
      style_usernames show_hidden_comments
      enable_auto_complete
      disable_cropped_thumbnails
      enable_safe_mode disable_responsive_mode
      move_related_thumbnails enable_hover_zoom hover_zoom_shift hover_zoom_play_audio hover_zoom_sticky_shift
    ] + [dmail_filter_attributes: %i[id words]]
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
    params = super + %i[name_matches about_me avatar_id level min_level max_level can_upload_free can_approve_posts order]
    params += %i[ip_addr] if can_search_ip_addr?
    params += %i[email_matches] if CurrentUser.is_admin?
    params
  end
end
