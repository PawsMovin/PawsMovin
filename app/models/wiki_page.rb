# frozen_string_literal: true

class WikiPage < ApplicationRecord
  class RevertError < Exception ; end

  before_validation :normalize_title
  before_validation :normalize_parent
  after_save :create_version
  validates :title, uniqueness: { :case_sensitive => false }
  validates :title, presence: true
  validates :title, tag_name: true, if: :title_changed?
  validates :body, presence: true, unless: -> { parent.present? }
  validates :title, length: { minimum: 1, maximum: 100 }
  validates :body, length: { maximum: PawsMovin.config.wiki_page_max_size }
  validate :user_not_limited
  validate :validate_rename
  validate :validate_not_locked

  before_destroy :validate_not_used_as_help_page
  before_destroy :log_destroy
  after_save :log_changes

  attr_accessor :skip_secondary_validations, :edit_reason
  belongs_to_creator
  belongs_to_updater
  has_one :tag, :foreign_key => "name", :primary_key => "title"
  has_one :artist, :foreign_key => "name", :primary_key => "title"
  has_many :versions, -> {order("wiki_page_versions.id ASC")}, :class_name => "WikiPageVersion", :dependent => :destroy

  def validate_not_used_as_help_page
    if HelpPage.find_by(wiki_page: title).present?
      errors.add(:wiki_page, "is used by a help page")
      throw :abort
    end
  end

  def log_destroy
    ModAction.log!(:wiki_page_delete, self, wiki_page_title: title, wiki_page_id: id)
  end

  def log_changes
    if title_changed? && !new_record?
      ModAction.log!(:wiki_page_rename, self, new_title: title, old_title: title_was)
    end
    if is_locked_changed?
      ModAction.log!(is_locked ? :wiki_page_lock : :wiki_page_unlock, self, wiki_page_title: title)
    end
  end

  module SearchMethods
    def titled(title)
      where("title = ?", title.downcase.tr(" ", "_"))
    end

    def recent
      order("updated_at DESC").limit(25)
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params)
      q = super

      if params[:title].present?
        q = q.where("title LIKE ? ESCAPE E'\\\\'", params[:title].downcase.strip.tr(" ", "_").to_escaped_for_sql_like)
      end

      q = q.attribute_matches(:body, params[:body_matches])

      q = q.where_user(:creator_id, :creator, params)

      if params[:hide_deleted].to_s.truthy?
        q = q.where("is_deleted = false")
      end

      q = q.attribute_matches(:is_locked, params[:is_locked])

      case params[:order]
      when "title"
        q = q.order("title")
      when "post_count"
        q = q.includes(:tag).order("tags.post_count desc nulls last").references(:tags)
      else
        q = q.apply_basic_order(params)
      end

      q
    end
  end

  module ApiMethods
    def method_attributes
      super + [:creator_name, :category_id]
    end
  end

  extend SearchMethods
  include ApiMethods

  def user_not_limited
    allowed = CurrentUser.can_wiki_edit_with_reason
    if allowed != true
      errors.add(:base, "User #{User.throttle_reason(allowed)}.")
      false
    end
    true
  end

  def validate_not_locked
    if is_locked? && !CurrentUser.is_janitor?
      errors.add(:is_locked, "and cannot be updated")
      return false
    end
  end

  def validate_rename
    return if !will_save_change_to_title? || skip_secondary_validations

    tag_was = Tag.find_by_name(Tag.normalize_name(title_was))
    if tag_was.present? && tag_was.post_count > 0
      errors.add(:title, "cannot be changed: '#{tag_was.name}' still has #{tag_was.post_count} posts. Move the posts and update any wikis linking to this page first.")
    end
  end

  def revert_to(version)
    if id != version.wiki_page_id
      raise RevertError.new("You cannot revert to a previous version of another wiki page.")
    end

    self.title = version.title
    self.body = version.body
    self.parent = version.parent
  end

  def revert_to!(version)
    revert_to(version)
    save!
  end

  def normalize_title
    self.title = title.downcase.tr(" ", "_")
  end

  def self.normalize_other_name(name)
    name.unicode_normalize(:nfkc).gsub(/[[:space:]]+/, " ").strip.tr(" ", "_")
  end

  def normalize_parent
    self.parent = nil if parent == ""
  end

  def skip_secondary_validations=(value)
    @skip_secondary_validations = value.to_s.truthy?
  end

  def category_id
    Tag.category_for(title)
  end

  def pretty_title
    title&.tr("_", " ") || ''
  end

  def pretty_title_with_category
    return pretty_title if category_id == 0
    "#{Tag.category_for_value(category_id)}: #{pretty_title}"
  end

  def wiki_page_changed?
    saved_change_to_title? || saved_change_to_body? || saved_change_to_is_locked? || saved_change_to_parent?
  end

  def create_new_version
    versions.create(
      updater_id: CurrentUser.user.id,
      updater_ip_addr: CurrentUser.ip_addr,
      title: title,
      body: body,
      is_locked: is_locked,
      parent: parent,
      reason: edit_reason,
    )
  end

  def create_version
    if wiki_page_changed?
      create_new_version
    end
  end

  def post_set
    @post_set ||= PostSets::Post.new(title, 1, 4)
  end

  def tags
    body.scan(/\[\[(.+?)\]\]/).flatten.map do |match|
      if match =~ /^(.+?)\|(.+)/
        $1
      else
        match
      end
    end.map {|x| x.downcase.tr(" ", "_").to_s}.uniq
  end

  def visible?
    true
  end
end
