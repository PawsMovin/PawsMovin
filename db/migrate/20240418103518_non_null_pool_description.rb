class NonNullPoolDescription < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:pools, :description, from: nil, to: "")
    change_column_null(:pools, :description, false, "")
  end
end
