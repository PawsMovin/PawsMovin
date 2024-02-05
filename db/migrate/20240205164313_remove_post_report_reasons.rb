class RemovePostReportReasons < ActiveRecord::Migration[7.1]
  def change
    drop_table :post_report_reasons do |t|
      t.reason :string, null: false
      t.integer :creator_id, foreign_key: { to_table: :users }, null: false
      t.inet :creator_ip_address
      t.string :description, null: false
      t.timestamps
    end

    remove_column :tickets, :report_reason, :string, foreign_key: { to_table: :post_report_reasons }
  end
end
