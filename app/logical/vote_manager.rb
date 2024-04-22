# frozen_string_literal: true

module VoteManager
  class NeedUnvoteError < StandardError; end
  class NoVoteError < StandardError; end

  ISOLATION = Rails.env.test? ? {} : { isolation: :repeatable_read }
end
