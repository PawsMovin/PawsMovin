# frozen_string_literal: true

class AddUnreadNotificationCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column(:users, :unread_notification_count, :integer, null: false, default: 0)
  end
end
