# frozen_string_literal: true

class TicketPolicy < ApplicationPolicy
  def index?
    unbanned?
  end

  def show?
    unbanned? && (!record.is_a?(Ticket) || record.can_see_details?(user))
  end

  def create?
    return false unless unbanned?
    if record.is_a?(Ticket)
      record.can_create_for?(user)
    elsif record.is_a?(ApplicationRecord)
      Ticket.new(model: record).can_create_for?(user)
    else
      true
    end
  end

  def update?
    user.is_moderator?
  end

  def claim?
    user.is_moderator?
  end

  def unclaim?
    user.is_moderator?
  end

  def permitted_attributes_for_new
    %i[model_id model_type report_type]
  end

  def permitted_attributes_for_create
    %i[model_id model_type reason report_type]
  end

  def permitted_attributes_for_update
    %i[response status record_type send_update_dmail]
  end

  def permitted_search_params
    params = %i[model_type status order model_id creator_id creator_name]
    params += %i[accused_name accused_id claimant_id claimant_name reason] if user.is_moderator?
    params
  end
end
