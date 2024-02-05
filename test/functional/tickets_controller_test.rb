require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  def assert_ticket_create_permissions(users, model:, **params)
    users.each do |user, allow_create|
      if allow_create
        assert_difference(-> { Ticket.count }) do
          post_auth tickets_path, user, params: { ticket: { **params, model_id: model.id, model_type: model.class.name, reason: "test" } }
          assert_response :redirect
        end
      else
        assert_no_difference(-> { Ticket.count }) do
          post_auth tickets_path, user, params: { ticket: { **params, model_id: @content.id, reason: "test" } }
          assert_response :forbidden
        end
      end
    end
  end

  context "The tickets controller" do
    setup do
      @admin = create(:admin_user)
      @bystander = create(:user)
      @reporter = create(:user)
      @bad_actor = create(:user, created_at: 2.weeks.ago)
    end

    context "update action" do
      setup do
        as(@bad_actor) do
          @ticket = create(:ticket, creator: @reporter, model: create(:comment))
        end
      end

      should "send a new dmail if the status is changed" do
        assert_difference(-> { Dmail.count }, 2) do
          put_auth ticket_path(@ticket), @admin, params: { ticket: { status: "approved", response: "abc" } }
        end
      end

      should "send a new dmail if the response is changed" do
        assert_no_difference(-> { Dmail.count }) do
          put_auth ticket_path(@ticket), @admin, params: { ticket: { response: "abc" } }
        end

        assert_difference(-> { Dmail.count }, 2) do
          put_auth ticket_path(@ticket), @admin, params: { ticket: { response: "def", send_update_dmail: true } }
        end
      end

      should "reject empty responses" do
        assert_no_changes(-> { @ticket.reload.status }) do
          put_auth ticket_path(@ticket), @admin, params: { ticket: { status: "approved", response: "" } }
        end
      end
    end

    context "for a forum ticket" do
      setup do
        as @bad_actor do
          @content = create(:forum_topic, creator: @bad_actor).original_post
        end
      end

      should "restrict reporting" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
        @content.update_columns(is_hidden: true)
        assert_ticket_create_permissions([[@bystander, false], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        get_auth ticket_path(@ticket), @admin
        assert_response :success
        get_auth ticket_path(@ticket), @reporter
        assert_response :success
        get_auth ticket_path(@ticket), @bystander
        assert_response :success

        @content.topic.update_columns(is_hidden: true)
        get_auth ticket_path(@ticket), @bystander
        assert_response :forbidden

        @content.topic.update_columns(is_hidden: false)
        @content.update_columns(is_hidden: true)
        get_auth ticket_path(@ticket), @bystander
        assert_response :forbidden
      end
    end

    context "for a comment ticket" do
      setup do
        as @bad_actor do
          @content = create(:comment, creator: @bad_actor)
        end
      end

      should "restrict reporting" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
        @content.update_columns(is_hidden: true)
        assert_ticket_create_permissions([[@bystander, false], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "not restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        @content.update_columns(is_hidden: true)
        get_auth ticket_path(@ticket), @bystander
        assert_response :success
      end
    end

    context "for a dmail ticket" do
      setup do
        as @bad_actor do
          @content = create(:dmail, from: @bad_actor, to: @bystander, owner: @bystander)
        end
      end

      should "disallow reporting dmails you did not recieve" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, false], [@bad_actor, false]], model: @content)
      end

      should "restrict access" do
        @ticket = create(:ticket, creator: @bystander, model: @content)
        get_auth ticket_path(@ticket), @admin
        assert_response :success
        get_auth ticket_path(@ticket), @bystander
        assert_response :success
        get_auth ticket_path(@ticket), @bad_actor
        assert_response :forbidden
      end
    end

    context "for a wiki page ticket" do
      setup do
        as @bad_actor do
          @content = create(:wiki_page, creator: @bad_actor)
        end
      end

      should "allow reporting wiki pages" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "not restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        get_auth ticket_path(@ticket), @bystander
        assert_response :success
      end
    end

    context "for a pool ticket" do
      setup do
        as @bad_actor do
          @content = create(:pool, creator: @bad_actor)
        end
      end

      should "allow reporting pools" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "not restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        get_auth ticket_path(@ticket), @bystander
        assert_response :success
      end
    end

    context "for a set ticket" do
      setup do
        as @bad_actor do
          @content = create(:post_set, is_public: true, creator: @bad_actor)
        end
      end

      should "dissallow reporting sets you can't see" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
        @content.update_columns(is_public: false)
        assert_ticket_create_permissions([[@bystander, false], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "not restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        @content.update_columns(is_public: false)
        get_auth ticket_path(@ticket), @bystander
        assert_response :success
      end
    end

    context "for post tickets" do
      setup do
        as @bad_actor do
          @content = create(:post, uploader: @bad_actor)
        end
      end

      should "allow reports" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "not restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        get_auth ticket_path(@ticket), @bystander
        assert_response :success
      end
    end

    context "for user tickets" do
      setup do
        @content = create(:user)
      end

      should "allow reporting users" do
        assert_ticket_create_permissions([[@bystander, true], [@admin, true], [@bad_actor, true]], model: @content)
      end

      should "restrict access" do
        @ticket = create(:ticket, creator: @reporter, model: @content)
        get_auth ticket_path(@ticket), @reporter
        assert_response :success
        get_auth ticket_path(@ticket), @admin
        assert_response :success
        get_auth ticket_path(@ticket), @bystander
        assert_response :forbidden
      end
    end
  end
end
