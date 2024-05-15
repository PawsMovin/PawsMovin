# frozen_string_literal: true

class StoreUploadDirectUrl < ActiveRecord::Migration[7.1]
  def change
    add_column(:posts, :upload_url, :string)
    add_column(:uploads, :direct_url, :string)
  end
end
