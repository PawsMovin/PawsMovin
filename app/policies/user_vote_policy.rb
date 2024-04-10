# frozen_string_literal: true

class UserVotePolicy < ApplicationPolicy
  attr_reader :presenter

  def initialize(user, record)
    super
    if record.is_a?(UserPresenter)
      @presenter = record
      @record = record.user
    end
  end

  def index?
    return user.is_moderator? if record.present? && record.is_a?(model.model) # if we're referencing a specific model instance, only allow moderators
    return user.is_moderator? || user == record if presenter.present? # if we're in a UserPresenter, only show to the same user or Moderators
    user.is_member?
  end

  def lock?
    user.is_moderator?
  end

  def delete?
    user.is_admin?
  end

  def manage?
    lock? || delete?
  end

  def permitted_attributes
    %i[score]
  end

  def permitted_search_params
    params = super + %I[user_id user_name #{model.model_type}_id #{model.model_type}_creator_id #{model.model_type}_creator_name timeframe score]
    params += %i[user_ip_addr duplicates_only order] if can_search_ip_addr?
    params
  end

  protected

  def model
    UserVote
  end
end
