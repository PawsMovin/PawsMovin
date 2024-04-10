# frozen_string_literal: true

class PostFlagPolicy < ApplicationPolicy
  def create?
    unbanned? && !user.no_flagging?
  end

  def destroy?
    approver?
  end

  def permitted_attributes
    %i[post_id reason_name parent_id]
  end

  def permitted_search_params
    # creator_id and creator_name are special cased in the model search function
    params = super + %i[reason_matches creator_id creator_name post_id post_tags_match type is_resolved]
    params += %i[ip_addr] if can_search_ip_addr?
    params
  end
end
