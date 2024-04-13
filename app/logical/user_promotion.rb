# frozen_string_literal: true

class UserPromotion
  attr_reader :user, :promoter, :new_level, :options, :old_can_approve_posts, :old_unrestricted_uploads, :old_no_flagging, :old_no_replacements, :old_can_manage_aibur

  def initialize(user, promoter, new_level, options = {})
    @user = user
    @promoter = promoter
    @new_level = new_level
    @options = options
  end

  def promote!
    validate

    @old_can_approve_posts = user.can_approve_posts?
    @old_unrestricted_uploads = user.unrestricted_uploads?
    @old_no_flagging = user.no_flagging?
    @old_no_replacements = user.no_replacements?
    @old_can_manage_aibur = user.can_manage_aibur?

    user.level = new_level

    if options.key?(:can_approve_posts)
      user.can_approve_posts = options[:can_approve_posts]
    end

    if options.key?(:unrestricted_uploads)
      user.unrestricted_uploads = options[:unrestricted_uploads]
    end

    if options.key?(:no_flagging)
      user.no_flagging = options[:no_flagging]
    end

    if options.key?(:no_replacements)
      user.no_replacements = options[:no_replacements]
    end

    if options.key?(:can_manage_aibur)
      user.can_manage_aibur = options[:can_manage_aibur]
    end

    create_mod_actions

    user.save
  end

  private

  def flag_check(added, removed, flag, friendly_name)
    user_flag = user.send("#{flag}?")
    return if send("old_#{flag}") == user_flag

    if user_flag
      added << friendly_name
    else
      removed << friendly_name
    end
  end

  def create_mod_actions
    added = []
    removed = []

    flag_check(added, removed, "can_approve_posts", "approve posts")
    flag_check(added, removed, "unrestricted_uploads", "unrestricted uploads")
    flag_check(added, removed, "no_flagging", "flagging ban")
    flag_check(added, removed, "no_replacements", "replacements ban")
    flag_check(added, removed, "can_manage_aibur", "manage tag change requests")

    if added.any? || removed.any?
      ModAction.log!(:user_flags_change, user, user_id: user.id, added: added, removed: removed)
    end

    if user.level_changed?
      ModAction.log!(:user_level_change, user, user_id: user.id, level: user.level_string, old_level: user.level_string_was)
    end
  end

  def validate
    raise(User::PrivilegeError, "Can't demote owner") if user.is_owner? && !promoter.is_owner?
    raise(User::PrivilegeError, "Only owner can promote to admin") if new_level.to_i >= User::Levels::ADMIN && !promoter.is_owner?
  end
end
