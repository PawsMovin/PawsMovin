class RenameBulkUpdateRequestUser < ActiveRecord::Migration[7.1]
  def change
    rename_column :bulk_update_requests, :user_id, :creator_id
    rename_column :bulk_update_requests, :user_ip_addr, :creator_ip_addr
  end
end
