# frozen_string_literal: true

class DummyTicket
  def initialize(accused, post_id)
    @ticket = Ticket.new(
      id:         0,
      created_at: Time.now,
      updated_at: Time.now,
      creator_id: User.system.id,
      status:     "pending",
      model:      accused,
      reason:     "[User ##{accused.id}](https://pawsmov.in/users/#{accused.id}) (#{accused.name}) tried to reupload destroyed post ##{post_id}",
    )
  end

  def notify
    @ticket.push_pubsub("create")
  end
end
