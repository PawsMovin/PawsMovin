# frozen_string_literal: true

require "test_helper"
require_relative "helper"

module ModActions
  class UsersTest < ActiveSupport::TestCase
    include Helper
    include Rails.application.routes.url_helpers

    context "mod actions for users" do
      setup do
        @target = create(:user)
        @original = @target.dup
        set_count!
      end

      should "format user_blacklist_change correctly" do
        @target.update!(is_admin_edit: true, blacklisted_tags: "aaa bbb")

        assert_matches(
          actions: %w[user_blacklist_change],
          text:    "Edited blacklist of #{user(@target)}",
          subject: @target,
        )
      end

      should "format user_delete correctly" do
        UserDeletion.new(@target, nil).send(:create_mod_action)

        assert_matches(
          actions: %w[user_delete],
          text:    "Deleted user #{user(@target)}",
          subject: @target,
        )
      end

      should "format user_flags_change correctly" do
        UserPromotion.new(@target, @admin, @target.level, { can_upload_free: true }).promote!

        assert_matches(
          actions: %w[user_flags_change],
          text:    "Changed #{user(@target)} flags. Added: [unrestricted uploads] Removed: []",
          subject: @target,
          added:   ["unrestricted uploads"],
          removed: [],
        )
      end

      should "format user_level_change correctly" do
        UserPromotion.new(@target, @admin, User::Levels::TRUSTED, {}).promote!

        assert_matches(
          actions:   %w[user_level_change],
          text:      "Changed #{user(@target)} level from #{@original.level_string} to #{@target.level_string}",
          subject:   @target,
          old_level: @original.level_string,
          level:     @target.level_string,
        )
      end

      should "format user_name_change correctly" do
        @target.log_name_change

        assert_matches(
          actions: %w[user_name_change],
          text:    "Changed name of #{user(@target)}",
          subject: @target,
        )
      end

      should "format user_text_change correctly" do
        @target.update!(is_admin_edit: true, profile_about: "xxx")

        assert_matches(
          actions: %w[user_text_change],
          text:    "Edited profile text of #{user(@target)}",
          subject: @target,
        )
      end

      should "format user_upload_limit_change correctly" do
        @target.update!(is_admin_edit: true, base_upload_limit: 20)

        assert_matches(
          actions:          %w[user_upload_limit_change],
          text:             "Changed upload limit of #{user(@target)} from #{@original.base_upload_limit} to #{@target.base_upload_limit}",
          subject:          @target,
          old_upload_limit: @original.base_upload_limit,
          upload_limit:     @target.base_upload_limit,
        )
      end
    end
  end
end
