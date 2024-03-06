class DropUserStatuses < ActiveRecord::Migration[7.1]
  def change
    drop_table :user_statuses
  end
end
