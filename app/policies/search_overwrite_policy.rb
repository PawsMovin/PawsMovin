# frozen_string_literal: true

# not a real policy, used as a replacement policy for inputs to return a specific value for the search check
class SearchOverwritePolicy < ApplicationPolicy
  attr_reader :value

  def initialize(value)
    super(nil, nil)
    @value = value
  end

  def can_search_attribute?(_attr)
    value
  end
end
