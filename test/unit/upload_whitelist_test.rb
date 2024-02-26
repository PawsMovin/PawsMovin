# frozen_string_literal: true

require "test_helper"

class UploadWhitelistTest < ActiveSupport::TestCase
  context "A upload whitelist" do
    setup do
      user = create(:trusted_user)
      CurrentUser.user = user

      @whitelist = create(:upload_whitelist, pattern: "*.pawsmov.in/*", note: "pawsmovin")
    end

    should "match" do
      assert_equal([true, nil], UploadWhitelist.is_whitelisted?(Addressable::URI.parse("https://static.pawsmov.in/123.png")))
      assert_equal([false, "123.com not in whitelist"], UploadWhitelist.is_whitelisted?(Addressable::URI.parse("https://123.com/what.png")))
    end

    should "bypass for admins" do
      CurrentUser.user.level = User::Levels::ADMIN
      PawsMovin.config.stubs(:bypass_upload_whitelist?).returns(true)
      assert_equal([true, "bypassed"], UploadWhitelist.is_whitelisted?(Addressable::URI.parse("https://123.com/what.png")))
    end
  end
end
