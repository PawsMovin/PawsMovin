#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

require "digest/md5"
require "tempfile"
require "net/http"

module Uploads
  def self.api_request(path)
    puts("-> GET #{read_resources['base_url']}#{path}")
    response = HTTParty.get("#{read_resources['base_url']}#{path}", {
      headers: { "User-Agent" => "pawmovin/seeding" },
    })
    JSON.parse(response.body)
  end

  def self.read_resources
    if @resources
      yield(@resources) if block_given?
      return @resources
    end
    @resources = YAML.load_file(Rails.root.join("db/seeds.yml"))
    @resources["tags"] << "randseed:#{Digest::MD5.hexdigest(Time.now.to_s)}" if @resources["tags"]&.include?("order:random")
    yield(@resources) if block_given?
    @resources
  end

  def self.get_posts(tags, limit = ENV.fetch("SEED_POST_COUNT", 100), page = 1)
    posts = api_request("/posts.json?limit=#{[320, limit].min}&tags=#{tags.join('%20')}&page=#{page}")["posts"]
    puts("Get Page #{page}")
    limit -= posts.length
    if posts.length == 320 && limit > 0
      posts += get_posts(tags, limit, page + 1)
    end
    posts
  end

  def self.run!(limit = ENV.fetch("SEED_POST_COUNT", 100).to_i)
    resources = read_resources
    search_tags = resources["post_ids"].blank? ? resources["tags"] : ["id:#{resources['post_ids'].join(',')}"]
    if search_tags.include?("order:random") && search_tags.none? { |tag| tag.starts_with?("randseed:") }
      search_tags << "randseed:#{SecureRandom.hex(16)}"
    end
    posts = get_posts(search_tags, limit)

    posts.each do |post|
      user = User.find(User.where(level: User::Levels::MEMBER).sample(1).pick(:id))
      CurrentUser.scoped(user) do
        next if Post.find_by(md5: post["file"]["md5"]).present?
        url = get_url(post, resources["base_url"])
        puts("#{url} (#{user.name})")
        post["sources"] << "#{resources['base_url']}/posts/#{post['id']}"
        post["tags"].each do |category, tags|
          Tag.find_or_create_by_name_list(tags.map { |tag| "#{category}:#{tag}" })
        end

        service = UploadService.new({
          uploader:         CurrentUser.user,
          uploader_ip_addr: CurrentUser.ip_addr,
          direct_url:       url,
          tag_string:       post["tags"].values.flatten.join(" "),
          source:           post["sources"].join("\n"),
          description:      post["description"],
          rating:           post["rating"],
        })

        upload = service.start!

        if upload.errors.any?
          puts("Failed to create upload: #{upload.errors.full_messages}")
        end

        if upload.post&.errors&.any?
          puts("Failed to create post: #{upload.post.errors.full_messages}")
        end
      end
    end
  end

  def self.get_url(post, base_url)
    return post["file"]["url"] unless post["file"]["url"].nil?
    puts("post #{post['id']} returned a nil url, attempting to reconstruct url.")
    return "https://static1.e621.net/data/#{post['file']['md5'][0..1]}/#{post['file']['md5'][2..3]}/#{post['file']['md5']}.#{post['file']['ext']}" if /e621\.net/i =~ base_url
    "https://static.pawsmov.in/#{post['file']['md5'][0..1]}/#{post['file']['md5'][2..3]}/#{post['file']['md5']}.#{post['file']['ext']}"
  end
end

Uploads.run!
