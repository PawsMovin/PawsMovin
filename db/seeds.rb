# frozen_string_literal: true

require "digest/md5"
require "tempfile"
require "net/http"

# Uncomment to see detailed logs
# ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)



module Seeds

  def self.run!
    create_aibur_category!
    begin
      User.system.update!(level: User::Levels::ADMIN)
      CurrentUser.as_system do
        Posts.run!
        Mascots.run!
      end
    ensure
      User.system.update!(level: User::Levels::SYSTEM)
    end
  end

  def self.create_aibur_category!
    ForumCategory.find_or_create_by!(name: "Tag Alias and Implication Suggestions") do |category|
      category.can_view = 0
    end
  end

  def self.api_request(path)
    response = HTTParty.get("https://e621.net#{path}", {
      headers: { "User-Agent" => "pawmovin/seeding" },
    })
    JSON.parse(response.body)
  end

  module Posts
    def self.run!(limit = ENV.fetch("SEED_POST_COUNT", 100))
      resources = YAML.load_file Rails.root.join("db/seeds.yml")
      resources["tags"] << "randseed:#{Digest::MD5.hexdigest(Time.now.to_s)}" if resources["tags"]&.include?("order:random")
      search_tags = resources["post_ids"].blank? ? resources["tags"] : ["id:#{resources['post_ids'].join(',')}"]
      json = Seeds.api_request("/posts.json?limit=#{limit}&tags=#{search_tags.join('%20')}")

      json["posts"].each do |post|
        url = get_url(post, resources["base_url"])
        puts url
        post["sources"] << "#{resources['base_url']}/posts/#{post['id']}"
        post["tags"].each do |category, tags|
          Tag.find_or_create_by_name_list(tags.map { |tag| "#{category}:#{tag}" })
        end

        service = UploadService.new({
          uploader: CurrentUser.user,
          uploader_ip_addr: CurrentUser.ip_addr,
          direct_url: url,
          tag_string: post["tags"].values.flatten.join(" "),
          source: post["sources"].join("\n"),
          description: post["description"],
          rating: post["rating"],
        })

        service.start!
      end
    end

    def self.get_url(post, base_url)
      return post["file"]["url"] unless post["file"]["url"].nil?
      puts "post #{post['id']} returned a nil url, attempting to reconstruct url."
      return "https://static1.e621.net/data/#{post['file']['md5'][0..1]}/#{post['file']['md5'][2..3]}/#{post['file']['md5']}.#{post['file']['ext']}" if /e621\.net/i =~ base_url
      "https://static.pawsmov.in/#{post['file']['md5'][0..1]}/#{post['file']['md5'][2..3]}/#{post['file']['md5']}.#{post['file']['ext']}"
    end
  end

  module Mascots
    def self.run!
      Seeds.api_request("/mascots.json").each do |mascot|
        puts mascot["url_path"]
        Mascot.create!(
          creator: CurrentUser.user,
          mascot_file: Downloads::File.new(mascot["url_path"]).download!,
          display_name: mascot["display_name"],
          background_color: mascot["background_color"],
          artist_url: mascot["artist_url"],
          artist_name: mascot["artist_name"],
          available_on_string: PawsMovin.config.app_name,
          active: mascot["active"],
          )
      end
    end
  end
end


unless Rails.env.test?
  Seeds.run!
end
