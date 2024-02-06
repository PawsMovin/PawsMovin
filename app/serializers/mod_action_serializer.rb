class ModActionSerializer < ActiveModel::Serializer
  attributes :id, :creator_id, :created_at, :updated_at, :action, :values

  def values
    object.format_json
  end
end
