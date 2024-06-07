# frozen_string_literal: true

class PostReplacement < ApplicationRecord
  belongs_to :post
  belongs_to :creator, class_name: "User"
  belongs_to :approver, class_name: "User", optional: true
  belongs_to :rejector, class_name: "User", optional: true
  belongs_to :uploader_on_approve, class_name: "User", foreign_key: :uploader_id_on_approve, optional: true
  attr_accessor :replacement_file, :replacement_url, :tags, :is_backup, :as_pending

  validate :user_is_not_limited, on: :create
  validate :post_is_valid, on: :create
  validate :set_file_name, on: :create
  validate :fetch_source_file, on: :create
  validate :update_file_attributes, on: :create
  validate on: :create do |replacement|
    FileValidator.new(replacement, replacement_file.path).validate
    throw :abort if errors.any?
  end
  validate :no_pending_duplicates, on: :create
  validate :write_storage_file, on: :create
  validates :reason, length: { minimum: 5, maximum: 150 }, presence: true, on: :create
  validates :rejection_reason, length: { maximum: 150 }, if: ->(rec) { rec.status == "rejected" }

  after_create -> { post.update_index }
  before_destroy :remove_files
  after_destroy -> { post.update_index }

  TAGS_TO_REMOVE_AFTER_ACCEPT = %w[better_version_at_source].freeze
  HIGHLIGHTED_TAGS = %w[better_version_at_source avoid_posting conditional_dnp].freeze

  def replacement_url_parsed
    return nil unless replacement_url =~ %r{\Ahttps?://}i
    begin
      Addressable::URI.heuristic_parse(replacement_url)
    rescue StandardError
      nil
    end
  end

  module PostMethods
    def post_is_valid
      if post.is_deleted?
        errors.add(:post, "is deleted")
        false
      end
    end
  end

  def no_pending_duplicates
    return true if is_backup

    if (destroyed_post = DestroyedPost.find_by(md5: md5))
      errors.add(:base, "An unexpected errror occured")
      DummyTicket.new(creator, destroyed_post.post_id).notify
      return
    end

    post = Post.where(md5: md5).first
    if post
      errors.add(:md5, "duplicate of existing post ##{post.id}")
      return false
    end
    replacements = PostReplacement.where(status: "pending", md5: md5)
    replacements.each do |replacement|
      errors.add(:md5, "duplicate of pending replacement on post ##{replacement.post_id}")
    end
    replacements.empty?
  end

  def user_is_not_limited
    return true if status == "original"
    uploadable = creator.can_upload_with_reason
    if uploadable != true
      errors.add(:creator, User.upload_reason_string(uploadable))
      throw(:abort)
    end

    # Janitor bypass replacement limits
    return true if creator.is_janitor?

    if post.replacements.where(creator_id: creator.id).where("created_at > ?", 1.day.ago).count >= PawsMovin.config.post_replacement_per_day_limit
      errors.add(:creator, "has already suggested too many replacements for this post today")
      throw(:abort)
    end
    if post.replacements.where(creator_id: creator.id).count >= PawsMovin.config.post_replacement_per_post_limit
      errors.add(:creator, "has already suggested too many total replacements for this post")
      throw(:abort)
    end
    true
  end

  def source_list
    source.split("\n").uniq.compact_blank
  end

  module StorageMethods
    def remove_files
      PostEvent.add(post_id, CurrentUser.user, :replacement_deleted, { replacement_id: id, md5: md5, storage_id: storage_id })
      PawsMovin.config.storage_manager.delete_replacement(self)
    end

    def fetch_source_file
      return if replacement_file.present?

      valid, reason = UploadWhitelist.is_whitelisted?(replacement_url_parsed)
      unless valid
        errors.add(:replacement_url, "is not whitelisted: #{reason}")
        throw(:abort)
      end

      download = Downloads::File.new(replacement_url_parsed)
      file = download.download!

      self.replacement_file = file
      self.source = "#{source}\n" + replacement_url
    rescue Downloads::File::Error
      errors.add(:replacement_url, "failed to fetch file")
      throw(:abort)
    end

    def update_file_attributes
      self.file_ext = file_header_to_file_ext(replacement_file.path)
      self.file_size = replacement_file.size
      self.md5 = Digest::MD5.file(replacement_file.path).hexdigest
      width, height = calculate_dimensions(replacement_file.path)
      self.image_width = width
      self.image_height = height
    end

    def set_file_name
      if replacement_file.present?
        self.file_name = replacement_file.try(:original_filename) || File.basename(replacement_file.path)
      else
        if replacement_url_parsed.blank? && replacement_url.present?
          errors.add(:replacement_url, "is invalid")
          throw(:abort)
        end
        if replacement_url_parsed.blank?
          errors.add(:base, "No file or replacement URL provided")
          throw(:abort)
        end
        self.file_name = replacement_url_parsed.basename
      end
    end

    def write_storage_file
      self.storage_id = SecureRandom.hex(16)
      PawsMovin.config.storage_manager.store_replacement(replacement_file, self, :original)
      thumbnail_file = PostThumbnailer.generate_thumbnail(replacement_file, is_video? ? :video : :image)
      PawsMovin.config.storage_manager.store_replacement(thumbnail_file, self, :preview)
    ensure
      thumbnail_file.try(:close!)
    end

    def replacement_file_path
      PawsMovin.config.storage_manager.replacement_path(self, file_ext, :original)
    end

    def replacement_thumb_path
      PawsMovin.config.storage_manager.replacement_path(self, file_ext, :preview)
    end

    def replacement_file_url
      PawsMovin.config.storage_manager.replacement_url(self)
    end

    def replacement_thumb_url
      PawsMovin.config.storage_manager.replacement_url(self, :preview)
    end
  end

  module ApiMethods
    def hidden_attributes
      super + %i[storage_id protected uploader_id_on_approve penalize_uploader_on_approve previous_details]
    end

    def method_attributes
      super + %i[file_url]
    end

    def file_url
      if post.deleteblocked?
        nil
      elsif post.visible?
        if original_file_visible_to?(CurrentUser)
          replacement_file_url
        else
          replacement_thumb_url
        end
      end
    end
  end

  module ProcessingMethods
    def approve!(penalize_current_uploader:)
      unless %w[pending original].include?(status)
        errors.add(:status, "must be pending or original to approve")
        return
      end

      update(previous_details: {
        width:  post.image_width,
        height: post.image_height,
        size:   post.file_size,
        ext:    post.file_ext,
        md5:    post.md5,
      })

      processor = UploadService::Replacer.new(post: post, replacement: self)
      processor.process!(penalize_current_uploader: penalize_current_uploader)
      PostEvent.add(post.id, CurrentUser.user, :replacement_accepted, { replacement_id: id, old_md5: post.md5, new_md5: md5 })
      post.update_index
    end

    def toggle_penalize!
      if status != "approved"
        errors.add(:status, "must be approved to penalize")
        return
      end

      if penalize_uploader_on_approve
        User.where(id: uploader_on_approve).update_all("own_post_replaced_penalize_count = own_post_replaced_penalize_count - 1")
      else
        User.where(id: uploader_on_approve).update_all("own_post_replaced_penalize_count = own_post_replaced_penalize_count + 1")
      end
      update_attribute(:penalize_uploader_on_approve, !penalize_uploader_on_approve)
    end

    def promote!
      if status != "pending"
        errors.add(:status, "must be pending to promote")
        return
      end

      upload = transaction do
        processor = UploadService.new(new_upload_params)
        new_upload = processor.start!
        if new_upload.valid? && new_upload.post&.valid?
          update_attribute(:status, "promoted")
          PostEvent.add(new_upload.post.id, CurrentUser.user, :replacement_promoted, { source_post_id: post.id })
        end
        new_upload
      end
      post.update_index
      upload
    end

    def reject!(user = CurrentUser.user, reason = "")
      if status != "pending"
        errors.add(:status, "must be pending to reject")
        return
      end

      PostEvent.add(post.id, user, :replacement_rejected, { replacement_id: id })
      update(status: "rejected", rejector: user, rejection_reason: reason)
      User.where(id: creator_id).update_all("post_replacement_rejected_count = post_replacement_rejected_count + 1")
      post.update_index
    end
  end

  module PromotionMethods
    def new_upload_params
      {
        uploader_id:      creator_id,
        uploader_ip_addr: creator_ip_addr,
        file:             PawsMovin.config.storage_manager.open(PawsMovin.config.storage_manager.replacement_path(self, file_ext, :original)),
        tag_string:       post.tag_string,
        rating:           post.rating,
        source:           "#{source}\n" + post.source,
        parent_id:        post.id,
        description:      post.description,
        locked_tags:      post.locked_tags,
        replacement_id:   id,
      }
    end
  end

  concerning :Search do
    class_methods do
      def search(params)
        q = super

        q = q.attribute_exact_matches(:file_ext, params[:file_ext])
        q = q.attribute_exact_matches(:md5, params[:md5])
        q = q.attribute_exact_matches(:status, params[:status])

        q = q.where_user(:creator_id, :creator, params)
        q = q.where_user(:approver_id, :approver, params)
        q = q.where_user(:rejector_id, :rejector, params)
        q = q.where_user(:uploader_id_on_approve, %i[uploader_name_on_approve uploader_id_on_approve], params)

        if params[:post_id].present?
          q = q.where("post_id in (?)", params[:post_id].split(",").first(100).map(&:to_i))
        end

        q.order(Arel.sql("CASE status WHEN 'pending' THEN 0 ELSE 1 END ASC, id DESC"))
      end

      def pending
        where(status: "pending")
      end

      def rejected
        where(status: "rejected")
      end

      def approved
        where(status: "approved")
      end

      def promoted
        where(status: "promoted")
      end

      def for_user(id)
        where(creator_id: id.to_i)
      end

      def for_uploader_on_approve(id)
        where(uploader_id_on_approve: id.to_i)
      end

      def penalized
        where(penalize_uploader_on_approve: true)
      end

      def not_penalized
        where(penalize_uploader_on_approve: false)
      end

      def visible(user)
        return where.not(status: "rejected") if user.is_anonymous?
        return all if user.is_janitor?
        where("creator_id = ? or status != ?", user.id, "rejected")
      end
    end
  end

  def original_file_visible_to?(user)
    user.is_janitor?
  end

  include ApiMethods
  include StorageMethods
  include FileMethods
  include ProcessingMethods
  include PromotionMethods
  include PostMethods

  def post_details
    {
      width:  post.image_width,
      height: post.image_height,
      size:   post.file_size,
      ext:    post.file_ext,
      md5:    post.md5,
    }
  end

  def current_details
    {
      width:  image_width,
      height: image_width,
      size:   file_size,
      ext:    file_ext,
      md5:    md5,
    }
  end

  def show_current?
    post && (status == "pending" || previous_details.blank?)
  end

  def details
    if status == "pending" && post
      post_details
    elsif previous_details.blank?
      return post_details if post
      nil
    else
      previous_details.transform_keys(&:to_sym)
    end
  end
end
