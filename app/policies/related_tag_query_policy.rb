# frozen_string_literal: true

class RelatedTagQueryPolicy < ApplicationPolicy
  def show?
    unbanned?
  end
end
