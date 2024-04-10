# frozen_string_literal: true

class ExceptionLogPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def permitted_search_params
    super + %i[commit class_name without_class_name]
  end
end
