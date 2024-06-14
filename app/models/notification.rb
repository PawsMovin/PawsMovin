# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  enum :category, %i[default new_post dmail mention feedback_create feedback_update feedback_delete]
  store_accessor :data, %i[post_id tag_name dmail_id dmail_title mention_id mention_type topic_id topic_title record_id record_type]
  store_accessor :data, %i[user_id], prefix: true
  after_commit :update_unread_count

  def h
    Rails.application.routes.url_helpers
  end

  def message
    case category
    when "new_post"
      "New post in tag [[#{tag_name}]]: post ##{post_id}"
    when "dmail"
      "@#{User.id_to_name(data_user_id)} sent you a dmail titled \"#{dmail_title}\""
    when "mention"
      base = "@#{User.id_to_name(data_user_id)} mentioned you in #{mention_type.humanize} ##{mention_id}"
      case mention_type
      when "Comment"
        base += " on post ##{post_id}"
      when "ForumPost"
        base += " in topic ##{topic_id} titled \"#{topic_title}\""
      end
      base
    when "feedback_create", "feedback_update", "feedback_delete"
      "@#{User.id_to_name(data_user_id)} #{category[9..]}d a #{record_type} on your account: record ##{record_id}"
    else
      "Unknown notification category: #{category}"
    end
  end

  def view_link
    case category
    when "new_post"
      h.post_path(post_id, n: id)
    when "dmail"
      h.dmail_path(dmail_id, n: id)
    when "mention"
      case mention_type
      when "Comment"
        h.post_path(post_id, anchor: "comment-#{mention_id}", n: id)
      when "ForumPost"
        h.forum_topic_path(topic_id, anchor: "forum_post_#{mention_id}", n: id)
      end
    when "feedback_create", "feedback_update", "feedback_delete"
      h.user_feedback_path(record_id, n: id)
    else
      "#"
    end
  end

  module SearchMethods
    def unread
      where(is_read: false)
    end

    def read
      where(is_read: true)
    end

    def for_user(user_id)
      where(user_id: user_id)
    end

    def search(params)
      q = super
      q.order(:is_read, id: :desc)
    end
  end

  extend SearchMethods

  def update_unread_count
    user.update!(unread_notification_count: user.notifications.unread.count)
  end

  def mark_as_read!
    update_column(:is_read, true)
    update_unread_count

    if dmail_id.present?
      Dmail.find_by(id: dmail_id, is_read: false).try(:mark_as_read!)
    end
  end

  def mark_as_unread!
    update_column(:is_read, false)
    update_unread_count
  end
end
