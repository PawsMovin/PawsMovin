# frozen_string_literal: true

class ModAction < ApplicationRecord
  belongs_to_creator
  belongs_to :subject, polymorphic: true, optional: true

  # inline results in rubucop aligning everything with :values
  VALUES = %i[
    user_id
    name
    total
    tag_name
    ip_addr
    change_desc
    reason reason_was
    description description_was
    antecedent consequent
    alias_id alias_desc
    implication_id implication_desc
    is_public
    added removed level level_was
    new_name old_name
    duration expires_at expires_at_was
    forum_category_id forum_category_name can_view old_can_view can_create old_can_create
    forum_topic_id forum_topic_title
    pool_name
    pattern old_pattern note hidden
    type type_was
    wiki_page wiki_page_title new_title old_title
  ].freeze

  store_accessor :values, *VALUES

  def self.log!(action, subject, **details)
    create!(action: action.to_s, subject: subject, values: details)
  end

  FORMATTERS = {
    ### Artist ###
    artist_lock: {
      text: ->(mod, _user) { "Locked artist ##{mod.subject_id}" },
      json: %i[],
    },
    artist_rename: {
      text: ->(mod, _user) { "Renamed artist ##{mod.subject_id} (\"#{mod.old_name}\":/artists/show_or_new?name=#{mod.old_name} -> \"#{mod.new_name}\":/artists/show_or_new?name=#{mod.new_name})" },
      json: %i[old_name new_name],
    },
    artist_unlock: {
      text: ->(mod, _user) { "Unlocked artist ##{mod.subject_id}" },
      json: %i[],
    },
    artist_user_link: {
      text: ->(mod, user) { "Linked #{user} to artist ##{mod.subject_id}" },
      json: %i[user_id],
    },
    artist_user_unlink: {
      text: ->(mod, user) { "Unlinked #{user} from artist ##{mod.subject_id}" },
      json: %i[user_id],
    },

    ### Ban ###
    ban_create: {
      text: ->(mod, user) do
        if mod.duration.is_a?(Numeric) && mod.duration < 0
          "Banned #{user} permanently"
        elsif mod.duration
          "Banned #{user} for #{mod.duration} #{'day'.pluralize(mod.duration)}"
        else
          "Banned #{user}"
        end
      end,
      json: %i[duration user_id],
    },
    ban_delete: {
      text: ->(_mod, user) { "Unbanned #{user}" },
      json: %i[user_id],
    },
    ban_update: {
      text: ->(mod, user) do
        text = "Updated ban ##{mod.subject_id} for #{user}"
        if mod.duration != mod.duration_was
          duration = mod.duration < 0 ? "permanent" : "#{mod.duration} #{'day'.pluralize(mod.duration)}"
          duration_was = mod.duration_was < 0 ? "permanent" : "#{mod.duration_was} #{'day'.pluralize(mod.duration_was)}"
          text += "\nChanged duration from #{duration_was} to #{duration}"
        end
        text += "\nChanged reason: [section=Old]#{values.reason_was}[/section] [section=New]#{values.reason}[/section]" if values.reason != values.reason_was
        text
      end,
      json: %i[duration duration_was reason reason_was user_id],
    },

    ### Comment ###
    comment_delete: {
      text: ->(mod, user) { "Deleted comment ##{mod.subject_id} by #{user}" },
      json: %i[user_id],
    },
    comment_hide: {
      text: ->(mod, user) { "Hid comment ##{mod.subject_id} by #{user}" },
      json: %i[user_id],
    },
    comment_unhide: {
      text: ->(mod, user) { "Unhid comment ##{mod.subject_id} by #{user}" },
      json: %i[user_id],
    },
    comment_update: {
      text: ->(mod, user) { "Edited comment ##{mod.subject_id} by #{user}" },
      json: %i[user_id],
    },

    ### Post Deletion Reason ###
    post_deletion_reason_create: {
      text: ->(mod, _user) { "Created post deletion reason \"#{mod.reason}\"" },
      json: %i[reason],
    },
    post_deletion_reason_delete: {
      text: ->(mod, user) { "Deleted post deletion reason \"#{mod.reason}\" by #{user}" },
      json: %i[reason user_id],
    },
    post_deletion_reasons_reorder: {
      text: ->(mod, _user) { "Changed the order of #{mod.total} post deletion reasons." },
      json: %i[total],
    },
    post_deletion_reason_update: {
      text: ->(mod, _user) do
        text = "Edited post deletion reason \"#{mod.reason}\""
        text += "\nChanged reason from \"#{mod.reason_was}\" to \"#{mod.reason}\"" if mod.reason != mod.reason_was
        text += "\nChanged description from \"#{mod.description_was}\" to \"#{mod.description}\"" if mod.description != mod.description_was
        text
      end,
      json: %i[reason reason_was description description_was],
    },

    ### Forum Category ###
    forum_category_create: {
      text: ->(mod, _user) do
        text = "Created forum category ##{mod.subject_id}"
        return text unless CurrentUser.user.level >= mod.can_view
        text += " (#{mod.forum_category_name})"
        text += "\nRestricted viewing topics to #{User.level_string(mod.can_view)}"
        text += "\nRestricted creating topics to #{User.level_string(mod.can_create)}"
        text
      end,
      json: ->(mod, _user) do
        values = %i[]
        return values unless CurrentUser.user.level >= mod.can_view
        values + %i[forum_category_name can_view can_create]
      end,
    },
    forum_category_delete: {
      text: ->(mod, _user) do
        text = "Deleted forum category ##{mod.subject_id}"
        return text unless CurrentUser.user.level >= mod.can_view
        "#{text} (#{mod.forum_category_name})"
      end,
      json: ->(mod, _user) do
        values = %i[]
        return values unless CurrentUser.user.level >= mod.can_view
        values + %i[forum_category_name can_view can_create]
      end,
    },
    forum_category_update: {
      text: ->(mod, _user) do
        text = "Updated forum category ##{mod.subject_id}"
        return text unless CurrentUser.user.level >= mod.can_view
        text += " (#{mod.forum_category_name})"
        text += "\nRestricted viewing topics to #{User.level_string(mod.can_view)} (Previously #{User.level_string(mod.old_can_view)})" if mod.can_view != mod.old_can_view
        text += "\nRestricted creating topics to #{User.level_string(mod.can_create)} (Previously #{User.level_string(mod.old_can_create)})" if mod.can_create != mod.old_can_create
        text
      end,
      json: ->(mod, _user) do
        values = %i[]
        return values unless CurrentUser.user.level >= mod.can_view
        values + %i[forum_category_name can_view can_create]
      end,
    },

    ### Forum Post ###
    forum_post_delete: {
      text: ->(mod, user) { "Deleted forum ##{mod.subject_id} in topic ##{mod.forum_topic_id} by #{user}" },
      json: %i[forum_topic_id user_id],
    },
    forum_post_hide: {
      text: ->(mod, user) { "Hid forum ##{mod.subject_id} in topic ##{mod.forum_topic_id} by #{user}" },
      json: %i[forum_topic_id user_id],
    },
    forum_post_unhide: {
      text: ->(mod, user) { "Unhid forum ##{mod.subject_id} in topic ##{mod.forum_topic_id} by #{user}" },
      json: %i[forum_topic_id user_id],
    },
    forum_post_update: {
      text: ->(mod, user) { "Edited forum ##{mod.subject_id} in topic ##{mod.forum_topic_id} by #{user}" },
      json: %i[forum_topic_id user_id],
    },

    ### Forum Topic ###
    forum_topic_delete: {
      text: ->(mod, user) { "Deleted topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },
    forum_topic_hide: {
      text: ->(mod, user) { "Hid topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },
    forum_topic_lock: {
      text: ->(mod, user) { "Locked topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },
    forum_topic_stick: {
      text: ->(mod, user) { "Stickied topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },
    forum_topic_unhide: {
      text: ->(mod, user) { "Unhid topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },
    forum_topic_unlock: {
      text: ->(mod, user) { "Unlocked topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },
    forum_topic_unstick: {
      text: ->(mod, user) { "Unstickied topic ##{mod.subject_id} (with title #{mod.forum_topic_title}) by #{user}" },
      json: %i[forum_topic_title user_id],
    },

    ### Help ###
    help_create: {
      text: ->(mod, _user) { "Created help entry \"#{mod.name}\":/help/#{HelpPage.normalize_name(mod.name)} ([[#{mod.wiki_page}]])" },
      json: %i[name wiki_page],
    },
    help_delete: {
      text: ->(mod, _user) { "Deleted help entry \"#{mod.name}\":/help/#{HelpPage.normalize_name(mod.name)} ([[#{mod.wiki_page}]])" },
      json: %i[name wiki_page],
    },
    help_update: {
      text: ->(mod, _user) { "Updated help entry \"#{mod.name}\":/help/#{HelpPage.normalize_name(mod.name)} ([[#{mod.wiki_page}]])" },
      json: %i[name wiki_page],
    },

    ### Mascot ###
    mascot_create: {
      text: ->(mod, _user) { "Created mascot ##{mod.subject_id}" },
      json: %i[],
    },
    mascot_delete: {
      text: ->(mod, _user) { "Deleted mascot ##{mod.subject_id}" },
      json: %i[],
    },
    mascot_update: {
      text: ->(mod, _user) { "Updated mascot ##{mod.subject_id}" },
      json: %i[],
    },

    ### Bulk Update Request ###
    mass_update: {
      text: ->(mod, _user) { "Mass updated [[#{mod.antecedent}]] -> [[#{mod.consequent}]]" },
      json: %i[antecedent consequent],
    },
    nuke_tag: {
      test: ->(mod, _user) { "Nuked tag [[#{mod.tag_name}]]" },
      json: %i[tag_name],
    },

    ### Pools ###
    pool_delete: {
      text: ->(mod, user) { "Deleted pool ##{mod.subject_id} (named #{mod.pool_name}) by #{user}" },
      json: %i[pool_name user_id],
    },

    ### Post Set ###
    set_change_visibility: {
      text: ->(mod, user) { "Made set ##{mod.subject_id} by #{user} #{mod.is_public ? 'public' : 'private'}" },
      json: %i[is_public user_id],
    },
    set_delete: {
      text: ->(mod, user) { "Deleted set ##{mod.subject_id} by #{user}" },
      json: %i[user_id],
    },
    set_update: {
      text: ->(mod, user) { "Edited set ##{mod.subject_id} by #{user}" },
      json: %i[user_id],
    },

    ### Alias ###
    tag_alias_create: {
      text: ->(mod, _user) { "Created tag alias #{mod.alias_desc}" },
      json: %i[alias_desc],
    },
    tag_alias_update: {
      text: ->(mod, _user) { "Updated tag alias #{mod.alias_desc}\n#{mod.change_desc}" },
      json: %i[alias_desc change_desc],
    },

    ### Implication ###
    tag_implication_create: {
      text: ->(mod, _user) { "Created tag implication #{mod.implication_desc}" },
      json: %i[implication_desc],
    },
    tag_implication_update: {
      text: ->(mod, _user) { "Updated tag implication #{mod.implication_desc}\n#{mod.change_desc}" },
      json: %i[implication_desc change_desc],
    },

    ### Takedowns ###
    takedown_process: {
      text: ->(mod, _user) { "Completed takedown ##{mod.subject_id}" },
      json: %i[],
    },
    takedown_delete: {
      text: ->(mod, _user) { "Deleted takedown ##{mod.subject_id}" },
      json: %i[],
    },

    ### Ticket ###
    ticket_claim: {
      text: ->(mod, _user) { "Claimed ticket ##{mod.subject_id}" },
      json: %i[],
    },
    ticket_unclaim: {
      text: ->(mod, _user) { "Unclaimed ticket ##{mod.subject_id}" },
      json: %i[],
    },
    ticket_update: {
      text: ->(mod, _user) { "Modified ticket ##{mod.subject_id}" },
      json: %i[],
    },

    ### Upload Whitelist ###
    upload_whitelist_create: {
      text: ->(mod, _user) do
        return "Created whitelist entry" if mod.hidden && !CurrentUser.is_admin?
        "Created whitelist entry '#{CurrentUser.is_admin? ? mod.pattern : mod.note}'"
      end,
      json: %i[hidden],
    },
    upload_whitelist_delete: {
      text: ->(mod, _user) do
        return "Deleted whitelist entry" if mod.hidden && !CurrentUser.is_admin?
        "Deleted whitelist entry '#{CurrentUser.is_admin? ? mod.pattern : mod.note}'"
      end,
      json: %i[hidden],
    },
    upload_whitelist_update: {
      text: ->(mod, _user) do
        return "Updated whitelist entry" if mod.hidden && !CurrentUser.is_admin?
        return "Updated whitelist entry '#{mod.old_pattern}' -> '#{mod.pattern}'" if mod.old_pattern && mod.old_pattern != mod.pattern && CurrentUser.is_admin?
        "Updated whitelist entry '#{CurrentUser.is_admin? ? mod.pattern : mod.note}'"
      end,
      json: %i[hidden],
    },

    user_blacklist_change: {
      text: ->(_mod, user) { "Edited blacklist of #{user}" },
      json: %i[user_id],
    },
    user_delete: {
      text: ->(_mod, user) { "Deleted user #{user}" },
      json: %i[user_id],
    },
    user_flags_change: {
      text: ->(mod, user) { "Changed #{user} flags. Added: [#{mod.added.join(', ')}] Removed: [#{mod.removed.join(', ')}]" },
      json: %i[added removed user_id],
    },
    user_level_change: {
      text: ->(mod, user) { "Changed #{user} level from #{mod.level_was} to #{mod.level}" },
      json: %i[level level_was user_id],
    },
    user_name_change: {
      text: ->(_mod, user) { "Changed name of #{user}" },
      json: %i[user_id],
    },
    user_text_change: {
      text: ->(_mod, user) { "Edited profile text of #{user}" },
      json: %i[user_id],
    },
    user_upload_limit_change: {
      text: ->(mod, user) { "Changed upload limit of #{user} from #{mod.old_upload_limit} to #{mod.new_upload_limit}" },
      json: %i[old_upload_limit new_upload_limit user_id],
    },

    ### User Feedback ###
    user_feedback_create: {
      text: ->(mod, user) { "Created #{mod.type} record ##{mod.subject_id} for #{user} with reason: #{mod.reason}" },
      json: %i[type reason user_id],
    },
    user_feedback_delete: {
      text: ->(mod, user) { "Deleted #{mod.type} record ##{mod.subject_id} for #{user} with reason: #{reason}" },
      json: %i[type reason user_id],
    },
    user_feedback_update: {
      text: ->(mod, user) do
        text = "Edited record ##{mod.subject_id} for #{user}"
        text += "\nChanged type from #{mod.type_was} to #{mod.type}" if mod.type != mod.type_was
        text += "\nChanged reason: [section=Old]#{mod.reason_was}[/section] [section=New]#{mod.reason}[/section]" if mod.reason != mod.reason_was
        text
      end,
      json: %i[type type_was reason reason_was user_id],
    },

    ### Wiki ###
    wiki_page_delete: {
      text: ->(mod, _user) { "Deleted wiki page [[#{mod.wiki_page_title}]]" },
      json: %i[wiki_page_title],
    },
    wiki_page_lock: {
      text: ->(mod, _user) { "Locked wiki page [[#{mod.wiki_page_title}]]" },
      json: %i[wiki_page_title],
    },
    wiki_page_rename: {
      text: ->(mod, _user) { "Renamed wiki page ([[#{mod.old_title}]] -> [[#{mod.new_title}]])" },
      json: %i[old_title new_title],
    },
    wiki_page_unlock: {
      text: ->(mod, _user) { "Unlocked wiki page [[#{mod.wiki_page_title}]]" },
      json: %i[wiki_page_title],
    },
  }.freeze

  def format_unknown(mod, _user)
    CurrentUser.is_admin? ? "Unknown action #{mod.action}: #{mod.values.inspect}" : "Unknown action #{mod.action}"
  end

  def user
    "\"#{User.id_to_name(user_id)}\":/users/#{user_id}"
  end

  def format_text
    FORMATTERS[action.to_sym]&.[](:text)&.call(self, user) || format_unknown(self, user)
  end

  def json_keys
    FORMATTERS[action.to_sym]&.[](:json) || (CurrentUser.is_admin? ? values.keys : [])
  end

  def format_json
    keys = FORMATTERS[action.to_sym]&.[](:json)
    return CurrentUser.is_admin? ? values : {} if keys.nil?
    keys = keys.call(self, user) if keys.is_a?(Proc)
    keys.index_with { |k| send(k) }
  end

  KNOWN_ACTIONS = FORMATTERS.keys.freeze

  module SearchMethods
    def search(params)
      q = super

      q = q.where_user(:creator_id, :creator, params)
      q = q.attribute_matches(:action, params[:action]&.split(","))
      q = q.attribute_matches(:subject_type, params[:subject_type])
      q = q.attribute_matches(:subject_id, params[:subject_id])

      q.apply_basic_order(params)
    end
  end

  module ApiMethods
    def method_attributes
      json_keys
    end

    def hidden_attributes
      super + %i[values]
    end

    def serializable_hash(*)
      return super.merge("#{subject_type.underscore}_id": subject_id) if subject
      super
    end
  end

  include ApiMethods
  extend SearchMethods
end
