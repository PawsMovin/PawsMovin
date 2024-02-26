# frozen_string_literal: true

require "test_helper"

class PostApprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post approvals controller" do
    setup do
      @approval = create(:post_approval)
    end

    context "index action" do
      should "render" do
        get post_approvals_path
        assert_response :success
      end
    end

    context "create action" do
      setup do
        @admin = create(:admin_user)
        as(@admin) do
          @post = create(:post, is_pending: true)
        end
      end

      should "render" do
        post_auth post_approvals_path, @admin, params: { post_id: @post.id, format: :json }
        assert_response :success
        @post.reload
        assert_not(@post.is_pending?)
      end
    end
  end
end
