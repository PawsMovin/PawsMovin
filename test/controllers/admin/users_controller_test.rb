# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    context "Admin::UsersController" do
      setup do
        @user = create(:user)
        @admin = create(:owner_user)
      end

      context "#edit" do
        should "render" do
          get_auth edit_admin_user_path(@user), @admin
          assert_response :success
        end
      end

      context "#update" do
        context "on a basic user" do
          should "fail for moderators" do
            put_auth admin_user_path(@user), create(:moderator_user), params: { user: { level: User::Levels::TRUSTED } }
            assert_response :forbidden
          end

          should "succeed" do
            put_auth admin_user_path(@user), @admin, params: { user: { level: User::Levels::TRUSTED } }
            assert_redirected_to(user_path(@user))
            @user.reload
            assert_equal(User::Levels::TRUSTED, @user.level)
          end

          should "rename" do
            assert_difference(-> { ModAction.count }, 1) do
              put_auth admin_user_path(@user), @admin, params: { user: { name: "renamed" } }
              assert_redirected_to(user_path(@user))
              assert_equal("renamed", @user.reload.name)
            end
          end
        end

        context "on an user with a blank email" do
          setup do
            @user = create(:user, email: "")
            PawsMovin.config.stubs(:enable_email_verification?).returns(true)
          end

          should "succeed" do
            put_auth admin_user_path(@user), @admin, params: { user: { level: User::Levels::TRUSTED } }
            assert_redirected_to(user_path(@user))
            @user.reload
            assert_equal(User::Levels::TRUSTED, @user.level)
          end

          should "prevent invalid emails" do
            put_auth admin_user_path(@user), @admin, params: { user: { email: "invalid" } }
            @user.reload
            assert_equal("", @user.email)
          end
        end

        context "on a user with duplicate email" do
          setup do
            @user1 = create(:user, email: "test@pawsmov.in")
            @user2 = create(:user, email: "test@pawsmov.in")
            PawsMovin.config.stubs(:enable_email_verification?).returns(true)
          end

          should "allow editing if the email is not changed" do
            put_auth admin_user_path(@user1), @admin, params: { user: { level: User::Levels::TRUSTED } }
            @user1.reload
            assert_equal(User::Levels::TRUSTED, @user1.level)
          end

          should "allow changing the email" do
            put_auth admin_user_path(@user1), @admin, params: { user: { email: "abc@pawsmov.in" } }
            @user1.reload
            assert_equal("abc@pawsmov.in", @user1.email)
          end
        end

        context "when updating the verification of emails" do
          should "allow setting to true" do
            user = create(:user, email_verification_key: "1")
            put_auth admin_user_path(user), @admin, params: { user: { verified: "true" } }

            assert_predicate user.reload, :is_verified?
          end

          should "allow setting to false" do
            user = create(:user)
            put_auth admin_user_path(user), @admin, params: { user: { verified: "false" } }

            assert_not_predicate user.reload, :is_verified?
          end
        end
      end
    end
  end
end
