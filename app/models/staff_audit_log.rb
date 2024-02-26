# frozen_string_literal: true

class StaffAuditLog < ApplicationRecord
  ACTIONS = %i[
    stuck_dnp
    min_upload_level_change
    post_owner_reassign
    staff_note_create
    staff_note_update
    staff_note_delete
    staff_note_undelete
  ].freeze

  VALUES = %i[
    reason
    target_id query post_ids
    new_level old_level
    new_user_id old_user_id
    staff_note_id body old_body
    ip_addr
  ].freeze

  store_accessor :values, *VALUES
  belongs_to :user, class_name: "User"

  def self.log(category, user, **details)
    create(user: user, action: category.to_s, values: details)
  end

  FORMATTERS = {
    stuck_dnp: {
      text: ->(log) { "Removed dnp tags from #{log.post_ids.length} #{'post'.pluralize(log.post_ids.length)} with query \"#{log.query}\"" },
      json: %i[query post_ids],
    },
    min_upload_level_change: {
      text: ->(log, _user) { "Changed the minimum upload level from [b]#{User::Levels.level_name(log.old_level)}[/b] to [b]#{User::Levels.level_name(log.new_level)}[/b]" },
      json: %i[new_level old_level],
    },
    post_owner_reassign: {
      text: ->(log) { "Reassigned #{log.post_ids.length} #{'post'.pluralize(log.post_ids.length)} with query \"#{log.query}\" from \"#{User.id_to_name(log.old_user_id)}\":/users/#{log.old_user_id} to \"#{User.id_to_name(log.new_user_id)}\":/users/#{log.new_user_id}" },
      json: %i[query post_ids old_user_ud new_user_id],
    },

    ### IP Ban ###
    ip_ban_create: {
      text: ->(log) { "Created ip ban #{log.ip_addr}\nBan reason: #{log.reason}" },
      json: %i[ip_addr reason],
    },
    ip_ban_delete: {
      text: ->(log) { "Deleted ip ban  #{log.ip_addr}\nBan reason: #{log.reason}" },
      json: %i[ip_addr reason],
    },

    ### Staff Notes ##
    staff_note_create: {
      text: ->(log) do
        "Created \"staff note ##{log.staff_note_id}\":#{Rails.application.routes.url_helpers.user_staff_notes_path(user_id: log.target_id, search: { id: log.staff_note_id })} for #{link_to_user(log.target_id)} with body: [section=Body]#{log.body}[/section]"
      end,
      json: %i[staff_note_id target_id body],
    },
    staff_note_update: {
      text: ->(log) do
        "Updated \"staff note ##{log.staff_note_id}\":#{Rails.application.routes.url_helpers.user_staff_notes_path(user_id: log.target_id, search: { id: log.staff_note_id })} for #{link_to_user(log.target_id)}\nChanged body: [section=Old]#{log.old_body}[/section]\n[section=New]#{log.body}[/section]"
      end,
      json: %i[staff_note_id target_id body old_body],
    },
    staff_note_delete: {
      text: ->(log) do
        "Deleted \"staff note ##{log.staff_note_id}\":#{Rails.application.routes.url_helpers.user_staff_notes_path(log.target_id, search: { id: log.staff_note_id })} for #{link_to_user(log.target_id)}"
      end,
      json: %i[staff_note_id target_id],
    },
    staff_note_undelete: {
      text: ->(log) do
        "Undeleted \"staff note ##{log.staff_note_id}\":#{Rails.application.routes.url_helpers.user_staff_notes_path(user_id: log.target_id, search: { id: log.staff_note_id })} for #{link_to_user(log.target_id)}"
      end,
      json: %i[staff_note_id target_id],
    },
  }.freeze

  def self.link_to_user(id)
    "\"#{User.id_to_name(id)}\":/users/#{id}"
  end

  def format_unknown(log)
    CurrentUser.is_admin? ? "Unknown action #{log.action}: #{mod.values.inspect}" : "Unknown action #{log.action}"
  end

  def format_text
    FORMATTERS[action.to_sym]&.[](:text)&.call(self) || format_unknown(self)
  end

  def format_json
    FORMATTERS[action.to_sym]&.[](:json)&.index_with { |k| send(k) } || (CurrentUser.is_admin? ? values : {})
  end

  KNOWN_ACTIONS = FORMATTERS.keys.freeze

  module SearchMethods
    def search(params)
      q = super

      q = q.where_user(:user_id, :user, params)
      if params[:action].present?
        q = q.where(action: params[:action].split(","))
      end

      q.apply_basic_order(params)
    end
  end

  extend SearchMethods
end
