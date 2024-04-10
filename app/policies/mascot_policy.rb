# frozen_string_literal: true

class MascotPolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end

  def permitted_attributes
    %i[mascot_file display_name background_color artist_url artist_name available_on_string active hide_anonymous]
  end
end
