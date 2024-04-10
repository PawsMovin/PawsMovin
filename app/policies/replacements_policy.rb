# frozen_string_literal: true

class ReplacementsPolicy < ApplicationPolicy
  def approve?
    approver?
  end

  def reject?
    approver?
  end

  def promote?
    approver?
  end

  def toggle_penalize?
    approver?
  end

  def destroy?
    user.is_admin?
  end

  def permitted_attributes
    %i[replacement_url replacement_file reason source]
  end
end
