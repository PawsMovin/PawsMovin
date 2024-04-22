# frozen_string_literal: true

class RemoveUploadsMd5Confirmation < ActiveRecord::Migration[7.1]
  def change
    remove_column(:uploads, :md5_confirmation, :string)
  end
end
