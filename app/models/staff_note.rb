class StaffNote < ApplicationRecord
  belongs_to_creator
  belongs_to_updater
  belongs_to :user

  scope :active, -> { where(is_deleted: false) }

  module SearchMethods
    def search(params)
      q = super

      q = q.where_user(:user_id, :user, params)
      q = q.where_user(:creator_id, :creator, params)
      q = q.where_user(:updater_id, :updater, params)

      if params[:without_system_user]&.truthy?
        q = q.where.not(creator: User.system)
      end

      if params[:is_deleted].present?
        q = q.attribute_matches(:is_deleted, params[:is_deleted])
      elsif !params[:include_deleted]&.truthy?
        q = q.active
      end

      q.apply_basic_order(params)
    end

    def default_order
      order("id desc")
    end
  end

  extend SearchMethods

  def can_delete?(user)
    return false unless user.is_staff?
    return true if user.is_owner? || creator_id == user.id
    user_id != user.id
  end

  def can_edit?(user)
    return false unless user.is_staff?
    user.id == creator_id || user.is_owner?
  end
end
