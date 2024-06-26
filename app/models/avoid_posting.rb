# frozen_string_literal: true

class AvoidPosting < ApplicationRecord
  belongs_to_creator
  belongs_to_updater

  has_many :versions, -> { order("avoid_posting_versions.id ASC") }, class_name: "AvoidPostingVersion", dependent: :destroy
  validates :artist_name, length: { maximum: 100 }
  validates :details, length: { maximum: 1024 }
  validates :staff_notes, length: { maximum: 4096 }
  before_validation :validate_artist_rename_not_conflicting, if: :will_save_change_to_artist_name?
  after_create :log_create
  after_update :log_update
  after_destroy :log_destroy
  after_save :update_artist, if: :saved_change_to_artist_name?
  after_save :create_version

  scope :active, -> { where(is_active: true) }
  scope :deleted, -> { where(is_active: false) }
  has_one :artist, foreign_key: "name", primary_key: "artist_name"

  attr_accessor :rename_artist

  module LogMethods
    def log_create
      ModAction.log!(:avoid_posting_create, self, artist_name: artist_name)
    end

    def log_update
      if saved_change_to_is_active?
        action = is_active? ? :avoid_posting_reactivate : :avoid_posting_deactivate
        ModAction.log!(action, self, artist_name: artist_name)
        # only log delete/undelete if only is_active changed (checking for 2 because of updated_at)
        return if previous_changes.length == 2
      end

      ModAction.log!(:avoid_posting_update, self, artist_name: artist_name)
    end

    def log_destroy
      ModAction.log!(:avoid_posting_delete, self, artist_name: artist_name)
    end
  end

  def create_version
    AvoidPostingVersion.create({
      artist_name:      artist_name,
      avoid_posting_id: id,
      details:          details,
      staff_notes:      staff_notes,
      is_active:        is_active,
    })
  end

  def status
    if is_active?
      "Active"
    else
      "Deleted"
    end
  end

  module ArtistMethods
    delegate :other_names, :other_names_string, :linked_user_id, :linked_user, :any_name_matches, to: :artist, allow_nil: true

    def validate_artist_rename_not_conflicting
      return unless rename_artist.to_s.truthy?
      return unless Artist.exists?(name: artist_name_was)
      if Artist.exists?(name: artist_name)
        errors.add(:base, "Cannot rename dnp and artist, a conflicting artist entry already exists")
        throw(:abort)
      end
    end

    def update_artist
      return unless rename_artist.to_s.truthy?
      artist = Artist.where(name: artist_name_before_last_save)
      return if artist.blank?
      return if Artist.exists?(name: artist_name)
      artist.update(name: artist_name)
    end
  end

  module ApiMethods
    def hidden_attributes
      attr = super
      attr += %i[staff_notes] unless CurrentUser.is_staff?
      attr
    end
  end

  module SearchMethods
    def for_artist(name)
      active.find_by(artist_name: name)
    end

    def artist_search(params)
      Artist.search(params.slice(:any_name_matches, :any_other_name_matches).merge({ id: params[:artist_id] }))
    end

    def search(params)
      q = super
      artist_keys = %i[artist_id any_name_matches any_other_name_matches]
      q = q.joins(:artist).merge(artist_search(params)) if artist_keys.any? { |key| params.key?(key) }

      q = q.attribute_matches(:artist_name, params[:artist_name])
      q = q.attribute_matches(:details, params[:details])
      q = q.attribute_matches(:staff_notes, params[:staff_notes])
      q = q.attribute_matches(:is_active, params[:is_active])
      q = q.where_user(:creator_id, :creator, params)
      q = q.where("creator_ip_addr <<= ?", params[:ip_addr]) if params[:ip_addr].present?
      q.apply_basic_order(params)
    end
  end

  include LogMethods
  include ApiMethods
  include ArtistMethods
  extend SearchMethods
end
