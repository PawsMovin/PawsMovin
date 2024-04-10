# frozen_string_literal: true

class PoolPolicy < ApplicationPolicy
  def gallery?
    index?
  end

  def destroy?
    user.is_janitor?
  end

  def revert?
    update?
  end

  def permitted_attributes
    [:name, :description, :category, :is_active, :post_ids_string, { post_ids: [] }]
  end

  def permitted_search_params
    super + %i[name_matches description_matches creator_id creator_name category is_active]
  end
end
