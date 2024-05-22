# frozen_string_literal: true

FactoryBot.define do
  factory(:user, aliases: %i[creator updater]) do
    sequence :name do |n|
      "user#{n}"
    end
    password { "password" }
    password_confirmation { "password" }
    sequence(:email) { |n| "user_email_#{n}@example.com" }
    default_image_size { "large" }
    base_upload_limit { 10 }
    level { User::Levels::MEMBER }
    created_at { Time.now }
    last_logged_in_at { Time.now }

    factory(:banned_user) do
      transient { ban_duration { 3 } }
      level { User::Levels::BANNED }
    end

    factory(:member_user) do
      level { User::Levels::MEMBER }
    end

    factory(:trusted_user) do
      level { User::Levels::TRUSTED }
    end

    factory(:janitor_user) do
      level { User::Levels::JANITOR }
      unrestricted_uploads { true }
      can_approve_posts { true }
    end

    factory(:moderator_user) do
      level { User::Levels::MODERATOR }
      can_approve_posts { true }
    end

    factory(:mod_user) do
      level { User::Levels::MODERATOR }
      can_approve_posts { true }
    end

    factory(:admin_user) do
      level { User::Levels::ADMIN }
      can_approve_posts { true }
      can_manage_aibur { true }
    end

    factory(:owner_user) do
      level { User::Levels::OWNER }
      can_approve_posts { true }
      can_manage_aibur { true }
    end
  end
end
