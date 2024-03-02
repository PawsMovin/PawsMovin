# frozen_string_literal: true

module PawsMovin
  class Configuration
    def version
      GitHelper.short_hash
    end

    def app_name
      "Paws Movin'"
    end

    def canonical_app_name
      "Paws Movin'"
    end

    def description
      "We keep your paws movin'!"
    end

    def domain
      "pawsmov.in"
    end

    # Force rating:s on this version of the site.
    def safe_mode?
      false
    end

    # The canonical hostname of the site.
    def hostname
      Socket.gethostname
    end

    # Contact email address of the admin.
    def contact_email
      "management@#{domain}"
    end

    def takedown_email
      "management@#{domain}"
    end

    def source_code_url
      "https://github.com/PawsMovin/PawsMovin"
    end

    # Stripped of any special characters.
    def safe_app_name
      app_name.gsub(/[^a-zA-Z0-9_-]/, "_")
    end

    module Users
      # If enabled, users must verify their email addresses.
      def enable_email_verification?
        Rails.env.production?
      end

      def anonymous_user_name
        "anonymous"
      end

      def anonymous_user
        user = User.new(name: anonymous_user_name, level: User::Levels::ANONYMOUS, created_at: Time.now)
        user.readonly!.freeze
        user
      end

      def system_user_name
        "System"
      end

      def system_user
        User.find_or_create_by!(name: system_user_name) do |user|
          user.level = User::Levels::SYSTEM
          user.email = "system@pawsmov.in"
          user.can_approve_posts = true
          user.can_upload_free = true
        end
      end

      def default_user_timezone
        "Central Time (US & Canada)"
      end

      # The default name to use for anyone who isn't logged in.
      def default_guest_name
        "Anonymous"
      end

      # Set the default level, permissions, and other settings for new users here.
      def customize_new_user(user)
        user.blacklisted_tags = default_blacklist.join("\n")
        user.comment_threshold = -10
        user.enable_auto_complete = true
        user.enable_keyboard_navigation = true
        user.per_page = 100
        user.show_post_statistics = true
        user.style_usernames = true
        user.move_related_thumbnails = true
        user.enable_hover_zoom = true
        user.hover_zoom_shift = true
      end

      def default_blacklist
        []
      end
    end

    def safeblocked_tags
      []
    end

    # This allows using statically linked copies of ffmpeg in non default locations. Not universally supported across
    # the codebase at this time.
    def ffmpeg_path
      "/usr/bin/ffmpeg"
    end

    # Thumbnail size
    def small_image_width
      300
    end

    # Large resize image width. Set to nil to disable.
    def large_image_width
      850
    end

    def large_image_prefix
      ""
    end

    def protected_path_prefix
      "deleted"
    end

    def protected_file_secret
      "abc123"
    end

    def replacement_path_prefix
      "replacements"
    end

    def replacement_file_secret
      "abc123"
    end

    def deleted_preview_url
      "/images/deleted-preview.png"
    end

    # When calculating statistics based on the posts table, gather this many posts to sample from.
    def post_sample_size
      300
    end

    # List of memcached servers
    def memcached_servers
      %w(127.0.0.1:11211)
    end

    def alias_implication_forum_category
      1
    end

    # After a post receives this many comments, new comments will no longer bump the post in comment/index.
    def comment_threshold
      40
    end

    def disable_throttles?
      false
    end

    def disable_age_checks?
      false
    end

    def disable_cache_store?
      false
    end

    # Members cannot post more than X comments in an hour.
    def member_comment_limit
      15
    end

    def comment_vote_limit
      10
    end

    def post_vote_limit
      3_000
    end

    def dmail_minute_limit
      1
    end

    def dmail_limit
      10
    end

    def dmail_day_limit
      50
    end

    def tag_suggestion_limit
      15
    end

    def forum_vote_limit
      50
    end

    # Artists creator or edited in the last hour
    def artist_edit_limit
      25
    end

    # Wiki pages created or edited in the last hour
    def wiki_edit_limit
      60
    end

    # Notes applied to posts edited or created in the last hour
    def note_edit_limit
      50
    end

    # Pools created in the last hour
    def pool_limit
      2
    end

    # Pools created or edited in the last hour
    def pool_edit_limit
      10
    end

    # Pools that you can edit the posts for in the last hour
    def pool_post_edit_limit
      30
    end

    # Members cannot create more than X post versions in an hour.
    def post_edit_limit
      150
    end

    def post_flag_limit
      20
    end

    # Flat limit that applies to all users, regardless of level
    def hourly_upload_limit
      30
    end

    def ticket_limit
      30
    end

    # Members cannot change the category of pools with more than this many posts.
    def pool_category_change_limit
      30
    end

    def post_replacement_per_day_limit
      2
    end

    def post_replacement_per_post_limit
      5
    end

    def replacements_minimum_posts
      20
    end

    def compact_uploader_minimum_posts
      10
    end

    def remember_key
      "abc123"
    end

    def tag_type_change_cutoff
      100
    end

    # Users cannot search for more than X regular tags at a time.
    def tag_query_limit
      40
    end

    # Return true if the given tag shouldn't count against the user's tag search limit.
    def is_unlimited_tag?(tag)
      !!(tag =~ /\A(-?status:deleted|rating:s.*|limit:.+)\z/i)
    end

    # After this many pages, the paginator will switch to sequential mode.
    def max_numbered_pages
      750
    end

    def comment_max_size
      10_000
    end

    def dmail_max_size
      50_000
    end

    def forum_post_max_size
      50_000
    end

    def note_max_size
      1_000
    end

    def pool_descr_max_size
      10_000
    end

    def post_descr_max_size
      50_000
    end

    def ticket_max_size
      5_000
    end

    def user_about_max_size
      50_000
    end

    def wiki_page_max_size
      250_000
    end

    def user_feedback_max_size
      20_000
    end

    def discord_site
    end

    def discord_secret
    end

    # Maximum size of an upload. If you change this, you must also change
    # `client_max_body_size` in your nginx.conf.
    def max_file_size
      100.megabytes
    end

    def max_file_sizes
      {
        "jpg"  => 100.megabytes,
        "png"  => 100.megabytes,
        "webp" => 100.megabytes,
        "gif"  => 20.megabytes,
        "webm" => 100.megabytes
      }
    end

    def max_apng_file_size
      20.megabytes
    end

    def max_mascot_file_sizes
      {
        "png"  => 1.megabyte,
        "jpg"  => 1.megabyte,
        "webp" => 1.megabyte,
      }
    end

    def max_mascot_width
      1000
    end

    def max_mascot_height
      1000
    end

    # Measured in seconds
    def max_video_duration
      3600
    end

    # Maximum resolution (width * height) of an upload. Default: 441 megapixels (21000x21000 pixels).
    def max_image_resolution
      15000 * 15000
    end

    # Maximum width of an upload.
    def max_image_width
      15000
    end

    # Maximum height of an upload.
    def max_image_height
      15000
    end

    def max_tags_per_post
      2000
    end

    # Permanently redirect all HTTP requests to HTTPS.
    #
    # https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
    # http://api.rubyonrails.org/classes/ActionDispatch/SSL.html
    def ssl_options
      {
        redirect: { exclude: ->(request) { request.subdomain == "insecure" } },
        hsts:     {
          expires:    1.year,
          preload:    true,
          subdomains: false,
        },
      }
    end

    # The method to use for storing image files.
    def storage_manager
      # Store files on the local filesystem.
      # base_dir - where to store files (default: under public/data)
      # base_url - where to serve files from (default: http://#{hostname}/data)
      # hierarchical: false - store files in a single directory
      # hierarchical: true - store files in a hierarchical directory structure, based on the MD5 hash
      StorageManager::Local.new(base_dir: "#{Rails.root}/public/data", hierarchical: true)

      # Select the storage method based on the post's id and type (preview, large, or original).
      # StorageManager::Hybrid.new do |id, md5, file_ext, type|
      #   if type.in?([:large, :original]) && id.in?(0..850_000)
      #     StorageManager::Local.new(base_dir: "/path/to/files", hierarchical: true)
      #   else
      #     StorageManager::Local.new(base_dir: "/path/to/files", hierarchical: true)
      #   end
      # end
    end

    # The method to use for backing up image files.
    def backup_storage_manager
      # Don't perform any backups.
      StorageManager::Null.new

      # Backup files to /mnt/backup on the local filesystem.
      # StorageManager::Local.new(base_dir: "/mnt/backup", hierarchical: false)
    end

    def enable_signups?
      true
    end

    def flag_reasons
      [
        {
          name:   "uploading_guidelines",
          reason: "Does not meet the [[uploading_guidelines|uploading guidelines]]",
          text:   "This post fails to meet the site's standards, be it for artistic worth, image quality, relevancy, or something else.\nKeep in mind that your personal preferences have no bearing on this. If you find the content of a post objectionable, simply [[help:blacklist|blacklist]] it."
        },
        {
          name:   "dnp_artist",
          reason: "The artist of this post is on the [[avoid_posting|avoid posting list]]",
          text:   "Certain artists have requested that their work is not to be published on this site, and were granted [[avoid_posting|Do Not Post]] status.\nSometimes, that status comes with conditions; see [[conditional_dnp]] for more information"
        },
        {
          name:   "pay_content",
          reason: "Paysite, commercial, or subscription content",
          text:   "We do not host paysite or commercial content of any kind. This includes Patreon leaks, reposts from piracy websites, and so on."
        },
        {
          name:   "trace",
          reason: "Trace of another artist's work",
          text:   "Images traced from other artists' artwork are not accepted on this site. Referencing from something is fine, but outright copying someone else's work is not.\nPlease, leave more information in the comments, or simply add the original artwork as the posts's parent if it's hosted on this site."
        },
        {
          name:   "previously_deleted",
          reason: "Previously deleted",
          text:   "Posts usually get removed for a good reason, and reuploading of deleted content is not acceptable.\nPlease, leave more information in the comments, or simply add the original post as this post's parent."
        },
        {
          name:   "real_porn",
          reason: "Real-life pornography",
          text:   "Posts featuring real-life pornography are not acceptable on this site. No exceptions.\nNote that images featuring non-erotic photographs are acceptable."
        },
        {
          name:   "corrupt",
          reason: "File is either corrupted, broken, or otherwise does not work",
          text:   "Something about this post does not work quite right. This may be a broken video, or a corrupted image.\nEither way, in order to avoid confusion, please explain the situation in the comments."
        },
        {
          name:   "inferior",
          reason: "Duplicate or inferior version of another post",
          text:   "A superior version of this post already exists on the site.\nThis may include images with better visual quality (larger, less compressed), but may also feature \"fixed\" versions, with visual mistakes accounted for by the artist.\nNote that edits and alternate versions do not fall under this category.",
          parent: true
        },
      ]
    end

    # Any custom code you want to insert into the default layout without
    # having to modify the templates.
    def custom_html_header_content
      nil
    end

    def flag_notice_wiki_page
      "help:flag_notice"
    end

    def replacement_notice_wiki_page
      "help:replacement_notice"
    end

    # The number of posts displayed per page.
    def posts_per_page
      100
    end

    def can_user_see_post?(user, post)
      return false if post.is_deleted? && !user.is_janitor?
      true
    end

    def user_needs_login_for_post?(post)
      false
    end

    def select_posts_visible_to_user(user, posts)
      posts.select {|x| can_user_see_post?(user, x)}
    end

    def enable_dimension_autotagging?
      true
    end

    # The default headers to be sent with outgoing http requests. Some external
    # services will fail if you don't set a valid User-Agent.
    def http_headers
      {
        "User-Agent" => "#{PawsMovin.config.safe_app_name}/#{PawsMovin.config.version}",
      }
    end

    def httparty_options
      # proxy example:
      # {http_proxyaddr: "", http_proxyport: "", http_proxyuser: nil, http_proxypass: nil}
      {
        timeout:     10,
        open_timout: 5,
        headers:     PawsMovin.config.http_headers,
      }
    end

    # you should override this
    def email_key
      "zDMSATq0W3hmA5p3rKTgD"
    end

    def mailgun_api_key
    end

    def mailgun_domain
    end

    def mail_from_addr
      "noreply@localhost"
    end

    def smtp_address
    end

    def smtp_port
    end

    def smtp_domain
    end

    def smtp_username
    end

    def smtp_password
    end

    def smtp_authentication
    end

    def smtp_tls
    end

    # disable this for tests
    def enable_sock_puppet_validation?
      !Rails.env.development?
    end

    def recommender_server
    end

    def iqdb_server
    end

    def opensearch_host
    end

    # Use a recaptcha on the signup page to protect against spambots creating new accounts.
    # https://developers.google.com/recaptcha/intro
    def enable_recaptcha?
      Rails.env.production? && PawsMovin.config.recaptcha_site_key.present? && PawsMovin.config.recaptcha_secret_key.present?
    end

    def recaptcha_site_key
    end

    def recaptcha_secret_key
    end

    def enable_image_cropping?
      true
    end

    def redis_url
    end

    def bypass_upload_whitelist?(user)
      user.is_admin? || user == User.system
    end

    # Additional video samples will be generated in these dimensions if it makes sense to do so
    # They will be available as additional scale options on applicable posts in the order they appear here
    def video_rescales
      {"720p" => [1280, 720], "480p" => [640, 480]}
    end

    def image_rescales
      []
    end

    def janitor_reports_discord_webhook_url
      nil
    end

    def moderator_stats_discord_webhook_url
      nil
    end

    def aibur_stats_discord_webhook_url
      nil
    end

    def reports_enabled?
      PawsMovin.config.reports_server.present?
    end

    def reports_server
    end

    def reports_server_internal
      PawsMovin.config.reports_server
    end

    def report_key
    end

    include Users
  end

  class EnvironmentConfiguration
    def custom_configuration
      @custom_configuration ||= CustomConfiguration.new
    end

    def env_to_boolean(method, var)
      is_boolean = method.to_s.end_with?("?")
      return true if is_boolean && var.truthy?
      return false if is_boolean && var.falsy?
      var
    end

    def method_missing(method, *)
      var = ENV["PAWSMOVIN_#{method.to_s.upcase.chomp('?')}"]

      if var.present?
        env_to_boolean(method, var)
      else
        custom_configuration.send(method, *)
      end
    end
  end

  def config
    @configuration ||= EnvironmentConfiguration.new
  end

  module_function :config
end
