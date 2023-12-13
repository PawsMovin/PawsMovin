class CreateUserTextVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_text_versions do |t|
      t.references :updater, foreign_key: { to_table: :users }, null: false
      t.inet :updater_ip_addr, null: false
      t.references :user, null: false
      t.string :about_text, null: false
      t.string :artinfo_text, null: false
      t.string :blacklist_text, null: false
      t.integer :version, null: false, default: 1
      t.string :text_changes, null: false, array: true, default: []
      t.datetime :created_at, null: false
    end
  end
end
