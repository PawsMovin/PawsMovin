#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

users = User.where(level: User::Levels::MEMBER)

users.each do |user|
  CurrentUser.scoped(user) do
    count = rand(200..700)
    Rails.logger.debug { "Creating #{count} favorites for #{user.name}" }
    Post.find(Post.pluck(:id).sample(count)).each do |post|
      FavoriteManager.add!(user: CurrentUser.user, post: post)
    rescue Favorite::Error, ActiveRecord::RecordInvalid
      # ignore
    end
  end
end
