# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    def update?
      user.is_admin?
    end

    def alt_list?
      user.is_admin?
    end

    def edit_blacklist?
      update_blacklist?
    end

    def update_blacklist?
      user.is_admin?
    end

    def request_password_reset?
      password_reset?
    end

    def password_reset?
      user.is_owner?
    end

    def permitted_attributes
      attr = %i[profile_about profile_artinfo base_upload_limit level enable_privacy_mode unrestricted_uploads can_approve_posts no_flagging no_replacements can_manage_aibur no_aibur_voting force_name_change]
      attr += %i[email title] if user.is_owner?
      attr
    end
  end
end
