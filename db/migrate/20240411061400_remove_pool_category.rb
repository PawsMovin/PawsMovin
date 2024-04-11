class RemovePoolCategory < ActiveRecord::Migration[7.1]
  def change
    remove_column(:pools, :category, :string, null: false, default: "series")
    remove_column(:pool_versions, :category, :string)
  end
end
