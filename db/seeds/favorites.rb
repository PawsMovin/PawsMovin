#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

users = User.where(level: User::Levels::MEMBER)

users.each do |user|
  CurrentUser.scoped(user) do
    count = rand(200..700)
    puts "Creating #{count} favorites for #{user.name}"
    Post.find(Post.pluck(:id).sample(count)).each do |post|
      begin
        FavoriteManager.add!(user: CurrentUser.user, post: post)
      rescue Favorite::Error, ActiveRecord::RecordInvalid => x
        # ignore
      end
    end
  end
end
