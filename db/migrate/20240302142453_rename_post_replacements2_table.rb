class RenamePostReplacements2Table < ActiveRecord::Migration[7.1]
  def change
    rename_table :post_replacements2, :post_replacements
  end
end
