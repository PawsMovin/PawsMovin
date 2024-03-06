# frozen_string_literal: true

require "test_helper"
require_relative "helper"

module ModActions
  class ForumTopicsTest < ActiveSupport::TestCase
    include Helper
    include Rails.application.routes.url_helpers

    context "mod actions for forum topics" do
      setup do
        as(@user) do
          @topic = create(:forum_topic)
        end
        set_count!
      end

      should "format forum_topic_delete correctly" do
        @topic.destroy

        assert_matches(
          actions:           %w[forum_topic_delete forum_post_delete],
          text:              "Deleted topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_hide correctly" do
        @topic.hide!

        assert_matches(
          actions:           %w[forum_topic_hide forum_post_update],
          text:              "Hid topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_lock correctly" do
        @topic.update!(is_locked: true)

        assert_matches(
          actions:           %w[forum_topic_lock forum_post_update],
          text:              "Locked topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_stick correctly" do
        @topic.update!(is_sticky: true)

        assert_matches(
          actions:           %w[forum_topic_stick forum_post_update],
          text:              "Stickied topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_update correctly" do
        @original = @topic.dup
        @topic.update!(title: "xxx")

        assert_matches(
          actions:           %w[forum_topic_update forum_post_update],
          text:              "Edited topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_unhide correctly" do
        @topic.update_columns(is_hidden: true)
        @topic.unhide!

        assert_matches(
          actions:           %w[forum_topic_unhide forum_post_update],
          text:              "Unhid topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_unlock correctly" do
        @topic.update_columns(is_locked: true)
        @topic.update!(is_locked: false)

        assert_matches(
          actions:           %w[forum_topic_unlock forum_post_update],
          text:              "Unlocked topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end

      should "format forum_topic_unstick correctly" do
        @topic.update_columns(is_sticky: true)
        @topic.update!(is_sticky: false)

        assert_matches(
          actions:           %w[forum_topic_unstick forum_post_update],
          text:              "Unstickied topic ##{@topic.id} (with title #{@topic.title}) by #{user(@user)}",
          subject:           @topic,
          forum_topic_title: @topic.title,
          user_id:           @user.id,
        )
      end
    end
  end
end
