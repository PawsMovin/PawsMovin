# frozen_string_literal: true

require "test_helper"

module Tags
  class AliasesControllerTest < ActionDispatch::IntegrationTest
    context "The tag aliases controller" do
      setup do
        @user = create(:user)
        @admin = create(:admin_user)
      end

      context "new action" do
        should "render" do
          get_auth new_tag_alias_path, @user
          assert_response :success
        end
      end

      context "create action" do
        should "create a forum post" do
          assert_difference("ForumTopic.count", 1) do
            post_auth tag_aliases_path, @user, params: { tag_alias: { antecedent_name: "aaa", consequent_name: "bbb", reason: "ccccc" } }
          end
          topic = ForumTopic.last
          post = topic.posts.last
          assert_redirected_to(forum_topic_path(topic, page: post.forum_topic_page, anchor: "forum_post_#{post.id}"))
        end

        should "create a pending alias" do
          assert_difference("ForumTopic.count") do
            post_auth tag_aliases_path, @user, params: { tag_alias: { antecedent_name: "aaa", consequent_name: "bbb", reason: "ccccc" } }
          end
          topic = ForumTopic.last
          post = topic.posts.last
          assert_redirected_to(forum_topic_path(topic, page: post.forum_topic_page, anchor: "forum_post_#{post.id}"))
        end
      end

      context "edit action" do
        setup do
          as(@admin) do
            @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
          end
        end

        should "render" do
          get_auth edit_tag_alias_path(@tag_alias), @admin
          assert_response :success
        end
      end

      context "update action" do
        setup do
          as(@admin) do
            @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
          end
        end

        context "for a pending alias" do
          setup do
            as(@admin) do
              @tag_alias.update(status: "pending")
            end
          end

          should "succeed" do
            put_auth tag_alias_path(@tag_alias), @admin, params: { tag_alias: { antecedent_name: "xxx" } }
            @tag_alias.reload
            assert_equal("xxx", @tag_alias.antecedent_name)
          end

          should "not allow changing the status" do
            put_auth tag_alias_path(@tag_alias), @admin, params: { tag_alias: { status: "active" } }
            @tag_alias.reload
            assert_equal("pending", @tag_alias.status)
          end
        end

        context "for an approved alias" do
          setup do
            @tag_alias.update_attribute(:status, "approved")
          end

          should "fail" do
            put_auth tag_alias_path(@tag_alias), @admin, params: { tag_alias: { antecedent_name: "xxx" } }
            @tag_alias.reload
            assert_equal("aaa", @tag_alias.antecedent_name)
          end
        end
      end

      context "index action" do
        setup do
          as(@admin) do
            @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
          end
        end

        should "list all tag alias" do
          get_auth tag_aliases_path, @admin
          assert_response :success
        end

        should "list all tag_alias (with search)" do
          get_auth tag_aliases_path, @admin, params: { search: { antecedent_name: "aaa" } }
          assert_response :success
        end
      end

      context "approve action" do
        setup do
          as(@admin) do
            @tag_alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
          end
        end

        should "approve the alias" do
          put_auth approve_tag_alias_path(@tag_alias), @admin, params: { format: :json }
          assert_response :success
          perform_enqueued_jobs(only: TagAliasJob)
          @tag_alias.reload
          assert_equal("active", @tag_alias.status)
        end

        should "not approve the alias if its estimated count is greater than allowed" do
          PawsMovin.config.stubs(:tag_change_request_update_limit).returns(1)
          create_list(:post, 2, tag_string: "aaa")
          put_auth approve_tag_alias_path(@tag_alias), @admin, params: { format: :json }
          assert_response :forbidden
          assert_equal("pending", @tag_alias.status)
        end
      end

      context "destroy action" do
        setup do
          as(@admin) do
            @tag_alias = create(:tag_alias)
          end
        end

        should "mark the alias as deleted" do
          assert_difference("TagAlias.count", 0) do
            delete_auth tag_alias_path(@tag_alias), @admin
            assert_equal("deleted", @tag_alias.reload.status)
          end
        end
      end
    end
  end
end
