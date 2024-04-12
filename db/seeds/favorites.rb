#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

users = User.where(level: User::Levels::MEMBER, favorite_count: ...1000).order("id asc")

users.each_with_index do |user, i|
  CurrentUser.scoped(user) do
    count = rand(500..7000)
    puts "Creating #{count} favorites for #{user.name} (#{i + 1}/#{users.count})"
    Post.find(Post.pluck(:id).sample(count)).each do |post|
      FavoriteManager.add!(user: CurrentUser.user, post: post)
      VoteManager.vote!(user: CurrentUser.user, post: post, score: rand(1..100) > 90 ? -1 : 1)
    rescue Favorite::Error, ActiveRecord::RecordInvalid
      # ignore
    end
  end
end
