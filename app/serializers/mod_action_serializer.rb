# frozen_string_literal: true

class ModActionSerializer < ActiveModel::Serializer
  attributes :id, :creator_id, :created_at, :updated_at, :action, :subject_id, :subject_type, :values

  def values
    hash = object.format_json
    hash[:"#{object.subject_type.underscore}_id"] = object.subject_id if object.subject_id.present?
    hash
    # object.format_json
  end
end
