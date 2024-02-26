# frozen_string_literal: true

module TicketHelper
  def generate_content_warnings(message)
    warnings = []
    if message.creator.is_banned? && message.creator.recent_ban.expires_at.nil?
      warnings << "The creator of this message is already permanently banned."
    end
    warnings << "The creator of this message already received a #{message.warning_type} for its contents." if message.warning_type
    warnings << "The reported message is older than 6 months." if message.updated_at < 6.months.ago

    warnings
  end

  def model_new_ticket_path(model:, **)
    new_ticket_path(model_id: model.id, model_type: model.class.name, **)
  end
end
