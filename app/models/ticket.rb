# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to_creator
  user_status_counter :ticket_count
  belongs_to :model, polymorphic: true
  belongs_to :claimant, class_name: "User", optional: true
  belongs_to :handler, class_name: "User", optional: true
  belongs_to :accused, class_name: "User", optional: true
  before_validation :initialize_fields, on: :create
  after_initialize :validate_type
  after_initialize :classify
  validates :reason, presence: true
  validates :reason, length: { minimum: 2, maximum: PawsMovin.config.ticket_max_size }
  validates :response, length: { minimum: 2 }, on: :update
  validates :report_type, presence: true
  validate :validate_report_type_for_ticket
  enum status: %i[pending partial approved].index_with(&:to_s)
  after_update :log_update
  after_update :create_dmail
  validate :validate_model_exists, on: :create
  validate :validate_creator_is_not_limited, on: :create

  scope :for_creator, ->(uid) {where('creator_id = ?', uid)}

  attr_accessor :record_type, :send_update_dmail

=begin
    Permission truth table.
    Type            | Field         | Access
    -----------------------------------------
    Any             | Username      | Admin+ / Current User
    Name Change     | Old Nme       | Any
    Any             | Created At    | Any
    Any             | Updated At    | Any
    Any             | Claimed By    | Admin+
    Any             | Status        | Any
    Any             | IP Address    | Admin+
    User Complaint  | Reported User | Admin+ / Current User
    Dmail           | Details       | Admin+ / Current User
    Comment         | Comment Link  | Any
    Comment         | Comment Author| Any
    Forum           | Forum Post    | Forum Visibility / Any
    Wiki            | Wiki Page     | Any
    Pool            | Pool          | Any
    Set             | Set           | Any
    Other           | Any           | N/A(No details shown)
    DMail           | Reason        | Admin+ / Current User
    User Complaint  | Reason        | Admin+ / Current User
    Any             | Reason        | Any
    DMail           | Response      | Admin+ / Current User
    User Complaint  | Response      | Admin+ / Current User
    Any             | Response      | Any
    Any             | Handled By    | Any
=end

  MODEL_TYPES = %w[Artist Comment Dmail ForumPost Pool Post PostSet User WikiPage].freeze

  module TicketTypes
    module Comment
      def can_create_for?(user)
        model&.visible_to?(user)
      end
    end

    module Dmail
      def can_create_for?(user)
        model&.visible_to?(user) && model.to_id == user.id
      end

      def can_see_details?(user)
        user.is_moderator? || (user.id == creator_id)
      end

      def bot_target_name
        model&.from&.name
      end
    end

    module ForumPost
      def can_create_for?(user)
        model.visible?(user)
      end

      def can_see_details?(user)
        if model
          model.visible?(user) || (user.id == creator_id)
        else
          true
        end
      end
    end

    module WikiPage
      def can_create_for?(user)
        true
      end

      def bot_target_name
        model&.title
      end
    end

    module Pool
      def can_create_for?(user)
        true
      end

      def bot_target_name
        model&.name
      end
    end

    module Post
      def subject
        reason.split("\n")[0] || "Unknown Report Type"
      end

      def can_create_for?(user)
        true
      end

      def bot_target_name
        model&.uploader&.name
      end
    end

    module PostSet
      def can_create_for?(user)
        model&.can_view?(user)
      end
    end

    module User
      def can_create_for?(user)
        true
      end

      def can_see_details?(user)
        user.is_moderator? || user.id == creator_id
      end

      def bot_target_name
        model&.name
      end
    end
  end

  module APIMethods
    def hidden_attributes
      hidden = []
      hidden += %i[claimant_id] unless CurrentUser.is_moderator?
      hidden += %i[creator_id] unless can_see_reporter?(CurrentUser)
      hidden += %i[model_type model_id reason] unless can_see_details?(CurrentUser)
      super + hidden
    end
  end

  module ValidationMethods
    def validate_type
      errors.add(:model_type, "is not valid")
    end

    def validate_report_type_for_ticket
      return if report_type == "report"
      return if report_type == "commendation" && model_type == "User"
      errors.add(:report_type, "is not valid")
    end

    def validate_creator_is_not_limited
      allowed = creator.can_ticket_with_reason
      if allowed != true
        errors.add(:creator, User.throttle_reason(allowed))
        return false
      end
      true
    end

    def validate_model_exists
      errors.add(model.name.underscore.to_sym, "does not exist") if model.nil?
    end

    def initialize_fields
      self.status = "pending"
      case model
      when Comment, ForumPost
        self.accused_id = model.creator_id
      when Dmail
        self.accused_id = model.from_id
      when User
        self.accused_id = model_id
      end
    end
  end

  module SearchMethods
    def for_accused(user_id)
      where(accused_id: user_id)
    end

    def active
      where(status: %w[pending partial])
    end

    def search(params)
      q = super.includes(:creator).includes(:claimant)

      q = q.where_user(:creator_id, :creator, params)
      q = q.where_user(:claimant_id, :claimant, params)
      q = q.where_user(:accused_id, :accused, params)

      if params[:model_type].present?
        q = q.where(model_type: params[:model_type])
      end

      if params[:model_id].present?
        q = q.where(model_id: params[:model_id])
      end

      if params[:reason].present?
        q = q.attribute_matches(:reason, params[:reason])
      end

      if params[:status].present?
        case params[:status]
        when "pending_claimed"
          q = q.where('status = ? and claimant_id is not null', 'pending')
        when "pending_unclaimed"
          q = q.where('status = ? and claimant_id is null', 'pending')
        else
          q = q.where('status = ?', params[:status])
        end
      end

      q.order(Arel.sql("CASE status WHEN 'pending' THEN 0 WHEN 'partial' THEN 1 ELSE 2 END ASC, id DESC"))
    end
  end

  module ClassifyMethods
    def classify
      extend(TicketTypes.const_get(model_type)) if TicketTypes.constants.map(&:to_s).include?(model_type)
    end
  end

  def report_type_pretty
    case report_type
    when "report"
      "reporting"
    when "commendation"
      "commending"
    else
      report_type
    end
  end

  def bot_target_name
    model&.creator&.name
  end

  def can_see_details?(user)
    true
  end

  def can_see_reporter?(user)
    user.is_moderator? || (user.id == creator_id)
  end

  def can_create_for?(user)
    false
  end

  def type_title
    "#{model.class.name.titlecase} #{report_type.titlecase}"
  end

  def subject
    if reason.length > 40
      "#{reason[0, 38]}..."
    else
      reason
    end
  end

  def open_duplicates
    Ticket.where(model: model, status: "pending")
  end

  def warnable?
    model.respond_to?(:user_warned!) && !model.was_warned? && pending?
  end

  module ClaimMethods
    def claim!(user = CurrentUser)
      transaction do
        ModAction.log!(:ticket_claim, self)
        update_attribute(:claimant_id, user.id)
        push_pubsub('claim')
      end
    end

    def unclaim!(user = CurrentUser)
      transaction do
        ModAction.log!(:ticket_unclaim, self)
        update_attribute(:claimant_id, nil)
        push_pubsub('unclaim')
      end
    end
  end

  module NotificationMethods
    def create_dmail
      should_send = saved_change_to_status? || (send_update_dmail.to_s.truthy? && saved_change_to_response?)
      return unless should_send

      msg = <<~MSG.chomp
        "Your ticket":#{Rails.application.routes.url_helpers.ticket_path(self)} has been updated by #{handler.pretty_name}.
        Ticket Status: #{status}

        Response: #{response}
      MSG
      Dmail.create_split(
        from_id: CurrentUser.id,
        to_id: creator.id,
        title: "Your ticket has been updated#{" to #{status}" if saved_change_to_status?}",
        body: msg,
        bypass_limits: true,
      )
    end

    def log_update
      return unless saved_change_to_response? || saved_change_to_status?

      ModAction.log!(:ticket_update, self)
    end
  end

  module PubSubMethods
    def pubsub_hash(action)
      {
        action: action,
        ticket: {
          id: id,
          user_id: creator_id,
          user: creator_id ? User.id_to_name(creator_id) : nil,
          claimant: claimant_id ? User.id_to_name(claimant_id) : nil,
          target: bot_target_name,
          status: status,
          model_id: model_id,
          model_type: model_type,
          report_type: report_type,
          reason: reason,
        }
      }
    end

    def push_pubsub(action)
      Cache.redis.publish("ticket_updates", pubsub_hash(action).to_json)
    end
  end

  include ClassifyMethods
  include ValidationMethods
  include APIMethods
  include ClaimMethods
  include NotificationMethods
  include PubSubMethods
  extend SearchMethods
end
