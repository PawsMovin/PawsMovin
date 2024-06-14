#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

users = User.left_joins(:followed_tags).where("tag_followers.user_id": nil).order("RANDOM()").limit(1000)

total = users.count
users.each_with_index do |user, i|
  CurrentUser.scoped(user) do
    count = rand(15..150)
    puts "Creating #{count} follows for #{user.name} (#{i + 1}/#{total})"
    Tag.where("post_count > 0").order("RANDOM()").limit(count).each do |tag|
      posts = Post.tag_match_system("#{tag.name} order:id_desc").limit(50).to_a
      next if posts.empty?
      offset = rand(0..posts.length - 1)
      user.followed_tags.create!(tag: tag, last_post_id: posts[offset].id)
    end
  end
  TagFollower.recount_all!
end
