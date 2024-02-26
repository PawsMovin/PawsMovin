# frozen_string_literal: true

class StaffAuditLogSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :created_at, :updated_at, :action, :values

  def values
    object.format_json
  end
end
