# frozen_string_literal: true

class AddTicketsReportType < ActiveRecord::Migration[7.1]
  def change
    add_column(:tickets, :report_type, :string, null: false, default: "report")
  end
end
