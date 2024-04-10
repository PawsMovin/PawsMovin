class RenameTagTypeVersions < ActiveRecord::Migration[7.1]
  def change
    rename_table(:tag_type_versions, :tag_versions)
    remove_column(:tag_versions, :old_type, :integer, null: false, default: 0)
    down do
      change_column_default(:tag_versions, :old_type, from: 0, to: nil)
    end
    rename_column(:tag_versions, :new_type, :category)
    rename_column(:tag_versions, :creator_id, :updater_id)
    add_column(:tag_versions, :reason, :string, null: false, default: "")
  end
end
