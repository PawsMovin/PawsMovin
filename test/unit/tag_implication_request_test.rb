# frozen_string_literal: true

require "test_helper"

class TagImplicationRequestTest < ActiveSupport::TestCase
  context "A tag implication request" do
    setup do
      @user = create(:user)
      CurrentUser.user = @user
    end

    should "handle invalid attributes" do
      tir = TagImplicationRequest.create(:antecedent_name => "", :consequent_name => "", :reason => "reason")
      assert(tir.invalid?)
    end

    should "create a tag implication" do
      assert_difference("TagImplication.count", 1) do
        TagImplicationRequest.create(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason")
      end
      assert_equal("pending", TagImplication.last.status)
    end

    should "create a forum topic" do
      assert_difference("ForumTopic.count", 1) do
        TagImplicationRequest.create(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason")
      end
    end

    should "create a forum post" do
      assert_difference("ForumPost.count", 1) do
        TagImplicationRequest.create(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason")
      end
    end
  end
end
