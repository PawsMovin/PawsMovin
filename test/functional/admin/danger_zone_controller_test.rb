# frozen_string_literal: true

require "test_helper"

class Admin::DangerZoneControllerTest < ActionDispatch::IntegrationTest
  context "The danger zone controller" do
    setup do
      @admin = create(:admin_user)
    end

    teardown do
      DangerZone.min_upload_level = User::Levels::MEMBER
    end

    context "index action" do
      should "render" do
        get_auth admin_danger_zone_index_path, @admin
        assert_response :success
      end
    end

    context "uploading limits action" do
      should "work" do
        put_auth uploading_limits_admin_danger_zone_index_path, @admin, params: { uploading_limits: { min_level: User::Levels::TRUSTED } }
        assert_equal DangerZone.min_upload_level, User::Levels::TRUSTED
      end
    end
  end
end
