# frozen_string_literal: true

class BulkUpdateRequestImporterPolicy < ApplicationPolicy
  def create?
    user.is_owner?
  end
end
