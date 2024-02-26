# frozen_string_literal: true

class ApiKey < ApplicationRecord
  belongs_to :user
  array_attribute :permissions
  array_attribute :permitted_ip_addresses

  before_validation :normalize_permissions
  validates :name, uniqueness: { scope: :user_id }, presence: true
  validates :key, uniqueness: true
  validate :validate_permissions, if: :permissions_changed?
  has_secure_token :key

  module ApiMethods
    def hidden_attributes
      super + %i[key]
    end
  end

  module PermissionMethods
    def has_permission?(ip, controller, action)
      ip_permitted?(ip) && action_permitted?(controller, action)
    end

    def ip_permitted?(ip)
      return true if permitted_ip_addresses.empty?
      permitted_ip_addresses.any? { |permitted_ip| ip.in?(permitted_ip) }
    end

    def action_permitted?(controller, action)
      return true if permissions.empty?

      permissions.any? do |permission|
        permission == "#{controller}:#{action}"
      end
    end

    def validate_permissions
      permissions.each do |permission|
        unless permission.in?(Permissions.list)
          errors.add(:permissions, "contains invalid permission '#{permission}'")
        end
      end
    end
  end

  module SearchMethods
    def visible(user)
      if user.is_owner?
        all
      else
        where(user: user)
      end
    end

    def search(params)
      q = super
      q = q.where_user(:user_id, :user, params)
      q.apply_basic_order(params)
    end
  end

  include ApiMethods
  include PermissionMethods
  extend SearchMethods

  def normalize_permissions
    self.permissions = permissions.compact_blank
  end

  def pretty_permissions
    permissions.map { |perm| Permissions.route(perm) }
  end
end
