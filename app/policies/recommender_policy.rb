# frozen_string_literal: true

class RecommenderPolicy < ApplicationPolicy
  def permitted_search_params
    super + %i[user_name user_id post_id maax_recommendations post_tags_match]
  end
end
