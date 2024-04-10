# frozen_string_literal: true

class BulkRelatedTagQueryPolicy < ApplicationPolicy
  def bulk?
    unbanned?
  end
end
