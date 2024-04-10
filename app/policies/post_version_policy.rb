# frozen_string_literal: true

class PostVersionPolicy < ApplicationPolicy
  def undo?
    unbanned?
  end
end
