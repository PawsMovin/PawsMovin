# frozen_string_literal: true

require "test_helper"
require_relative "helper"

module ModActions
  class ForumCategoriesTest < ActiveSupport::TestCase
    include Helper
    include Rails.application.routes.url_helpers

    context "mod actions for forum categories" do
      setup do
        @category = create(:forum_category, can_view: User::Levels::TRUSTED)
        @trusted = create(:trusted_user)
        set_count!
      end

      context "forum_category_create" do
        setup do
          @category = create(:forum_category, can_view: User::Levels::TRUSTED)
        end

        should "format correctly for users that can see the category" do
          as(@trusted) do
            assert_matches(
              actions:             %w[forum_category_create],
              text:                <<~TEXT.strip,
                Created forum category ##{@category.id} (#{@category.name})
                Restricted viewing topics to #{User.level_string(@category.can_view)}
                Restricted creating topics to #{User.level_string(@category.can_create)}
              TEXT
              subject:             @category,
              creator:             @admin,
              forum_category_name: @category.name,
              can_view:            @category.can_view,
              can_create:          @category.can_create,
            )
          end
        end

        should "format correctly for users that cannot see the category" do
          as(@user) do
            assert_matches(
              actions: %w[forum_category_create],
              text:    "Created forum category ##{@category.id}",
              subject: @category,
              creator: @admin,
            )
          end
        end
      end

      context "forum_category_delete" do
        should "format correctly for users that can see the category" do
          @category.destroy

          as(@trusted) do
            assert_matches(
              actions:             %w[forum_category_delete],
              text:                "Deleted forum category ##{@category.id} (#{@category.name})",
              subject:             @category,
              creator:             @admin,
              forum_category_name: @category.name,
              can_view:            @category.can_view,
              can_create:          @category.can_create,
            )
          end
        end

        should "format correctly for users that cannot see the category" do
          @category.destroy

          as(@user) do
            assert_matches(
              actions: %w[forum_category_delete],
              text:    "Deleted forum category ##{@category.id}",
              subject: @category,
              creator: @admin,
            )
          end
        end
      end

      context "forum_category_update" do
        setup do
          @original = @category.dup
        end

        context "with no changes" do
          should "format correctly for users that can see the category" do
            @category.save

            as(@trusted) do
              assert_matches(
                actions:                 %w[forum_category_update],
                text:                    "Updated forum category ##{@category.id} (#{@category.name})",
                subject:                 @category,
                creator:                 @admin,
                forum_category_name:     @category.name,
                old_forum_category_name: @original.name,
                can_view:                @category.can_view,
                old_can_view:            @original.can_view,
                can_create:              @category.can_create,
                old_can_create:          @original.can_create,
              )
            end
          end

          should "format correctly for users that cannot see the category" do
            @category.save

            as(@user) do
              assert_matches(
                actions: %w[forum_category_update],
                text:    "Updated forum category ##{@category.id}",
                subject: @category,
                creator: @admin,
              )
            end
          end
        end

        context "with name change" do
          should "format correctly for users that can see the category" do
            @category.update!(name: "xxx")

            as(@trusted) do
              assert_matches(
                actions:                 %w[forum_category_update],
                text:                    <<~TEXT.strip,
                  Updated forum category ##{@category.id} (#{@category.name})
                  Changed name from "#{@original.name}" to "#{@category.name}"
                TEXT
                subject:                 @category,
                creator:                 @admin,
                forum_category_name:     @category.name,
                old_forum_category_name: @original.name,
                can_view:                @category.can_view,
                old_can_view:            @original.can_view,
                can_create:              @category.can_create,
                old_can_create:          @original.can_create,
              )
            end
          end

          should "format correctly for users that cannot see the category" do
            @category.update!(name: "xxx")

            as(@user) do
              assert_matches(
                actions: %w[forum_category_update],
                text:    "Updated forum category ##{@category.id}",
                subject: @category,
                creator: @admin,
              )
            end
          end
        end

        context "with can_view change" do
          should "format correctly for users that can see the category" do
            @category.update!(can_view: User::Levels::ADMIN)

            as(@admin) do
              assert_matches(
                actions:                 %w[forum_category_update],
                text:                    <<~TEXT.strip,
                  Updated forum category ##{@category.id} (#{@category.name})
                  Restricted viewing topics to #{User.level_string(@category.can_view)} (Previously #{User.level_string(@original.can_view)})
                TEXT
                subject:                 @category,
                creator:                 @admin,
                forum_category_name:     @category.name,
                old_forum_category_name: @original.name,
                can_view:                @category.can_view,
                old_can_view:            @original.can_view,
                can_create:              @category.can_create,
                old_can_create:          @original.can_create,
              )
            end
          end

          should "format correctly for users that cannot see the category" do
            @category.update!(can_view: User::Levels::ADMIN)

            as(@user) do
              assert_matches(
                actions: %w[forum_category_update],
                text:    "Updated forum category ##{@category.id}",
                subject: @category,
                creator: @admin,
              )
            end
          end
        end

        context "with can_create change" do
          should "format correctly for users that can see the category" do
            @category.update!(can_create: User::Levels::ADMIN)

            as(@admin) do
              assert_matches(
                actions:                 %w[forum_category_update],
                text:                    <<~TEXT.strip,
                  Updated forum category ##{@category.id} (#{@category.name})
                  Restricted creating topics to #{User.level_string(@category.can_create)} (Previously #{User.level_string(@original.can_create)})
                TEXT
                subject:                 @category,
                creator:                 @admin,
                forum_category_name:     @category.name,
                old_forum_category_name: @original.name,
                can_view:                @category.can_view,
                old_can_view:            @original.can_view,
                can_create:              @category.can_create,
                old_can_create:          @original.can_create,
              )
            end
          end

          should "format correctly for users that cannot see the category" do
            @category.update!(can_create: User::Levels::ADMIN)

            as(@user) do
              assert_matches(
                actions: %w[forum_category_update],
                text:    "Updated forum category ##{@category.id}",
                subject: @category,
                creator: @admin,
              )
            end
          end
        end

        context "with all changes" do
          should "format correctly for users that can see the category" do
            @category.update!(name: "xxx", can_view: User::Levels::ADMIN, can_create: User::Levels::ADMIN)

            as(@admin) do
              assert_matches(
                actions:                 %w[forum_category_update],
                text:                    <<~TEXT.strip,
                  Updated forum category ##{@category.id} (#{@category.name})
                  Changed name from "#{@original.name}" to "#{@category.name}"
                  Restricted viewing topics to #{User.level_string(@category.can_view)} (Previously #{User.level_string(@original.can_view)})
                  Restricted creating topics to #{User.level_string(@category.can_create)} (Previously #{User.level_string(@original.can_create)})
                TEXT
                subject:                 @category,
                creator:                 @admin,
                forum_category_name:     @category.name,
                old_forum_category_name: @original.name,
                can_view:                @category.can_view,
                old_can_view:            @original.can_view,
                can_create:              @category.can_create,
                old_can_create:          @original.can_create,
              )
            end
          end

          should "format correctly for users that cannot see the category" do
            @category.update!(name: "xxx", can_view: User::Levels::ADMIN, can_create: User::Levels::ADMIN)

            as(@user) do
              assert_matches(
                actions: %w[forum_category_update],
                text:    "Updated forum category ##{@category.id}",
                subject: @category,
                creator: @admin,
              )
            end
          end
        end
      end
    end
  end
end
