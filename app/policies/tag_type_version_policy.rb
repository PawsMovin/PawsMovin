# frozen_string_literal: true

class TagTypeVersionPolicy < ApplicationPolicy
  def permitted_search_params
    %i[tag user_id user_name]
  end
end
