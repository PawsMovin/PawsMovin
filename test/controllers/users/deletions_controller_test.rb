# frozen_string_literal: true

require "test_helper"

module Users
  class DeletionsControllerTest < ActionDispatch::IntegrationTest
    context "in all cases" do
      setup do
        @user = create(:user, created_at: 2.weeks.ago)
      end

      context "#show" do
        should "render" do
          get_auth users_deletion_path, @user
          assert_response :success
        end
      end

      context "#destroy" do
        should "render" do
          delete_auth users_deletion_path, @user, params: { password: "password" }
          assert_redirected_to(posts_path)
        end
      end
    end
  end
end
