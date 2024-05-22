# frozen_string_literal: true

class Favorite < ApplicationRecord
  class Error < StandardError
  end

  class HiddenError < User::PrivilegeError
    def initialize(msg = "This users favorites are hidden")
      super
    end
  end

  belongs_to :post
  belongs_to :user, counter_cache: "favorite_count"
  scope :for_user, ->(user_id) { where("user_id = #{user_id.to_i}") }
end
