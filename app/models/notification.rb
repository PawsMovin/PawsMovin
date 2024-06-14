# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  enum :category, %i[default new_post]
  store_accessor :data, %i[post_id tag_name]
  after_commit :update_unread_count

  def h
    Rails.application.routes.url_helpers
  end

  def message
    case category
    when "new_post"
      "New post in tag [[#{tag_name}]]: \"post ##{post_id}\":#{view_link}"
    else
      "Unknown notification category: #{category}"
    end
  end

  def view_link
    case category
    when "new_post"
      h.post_path(post_id, n: id)
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
end
